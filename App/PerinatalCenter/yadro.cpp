#include "yadro.h"

#include <QDateTime>
#include <QDebug>
#include <QRandomGenerator>
#include <QRegularExpression>
#include <QSqlError>
#include <QSqlQuery>
#include <QStringList>
#include <QVariant>
#include <algorithm>

QSqlDatabase Yadro::s_db;
QString Yadro::s_connectionError;

namespace {
QString dbError(const QString &action, const QSqlQuery &query)
{
    qWarning().noquote() << action << query.lastError().nativeErrorCode();
    return QStringLiteral("Не удалось выполнить операцию «%1». Проверьте подключение и данные.").arg(action);
}

QString clean(const QString &value) { return value.trimmed(); }

bool validNewLogin(const QString &login)
{
    static const QRegularExpression pattern(QStringLiteral(R"(^(?:[^@\s]+@[^@\s]+\.[^@\s]+|\+?[0-9]{7,15})$)"));
    return pattern.match(login.trimmed()).hasMatch();
}

bool isUniqueError(const QSqlQuery &q)
{
    return q.lastError().nativeErrorCode() == QStringLiteral("23505");
}

QVariantMap patientRow(QSqlQuery &q)
{
    QVariantMap map;
    map["id"] = q.value(0).toInt();
    map["name"] = q.value(1).toString();
    map["sour_name"] = q.value(2).toString();
    map["full_name"] = q.value(2).toString() + " " + q.value(1).toString();
    map["policy"] = q.value(3).toString();
    map["pregnancy_period"] = q.value(4).toString();
    map["disease"] = q.value(5).toBool();
    map["department"] = q.value(6).toString();
    map["chamber"] = q.value(7).isNull() ? QString() : q.value(7).toString();
    map["status"] = q.value(8).toString();
    map["placementVersion"] = q.value(11).toInt();
    map["departmentKind"] = q.value(10).toString();
    map["discharged"] = q.value(9).toBool();
    return map;
}

const char *lastPlacementSql = R"SQL(
    SELECT p.id, p.name, p.sour_name, p.policy, p.pregnancy_period, p.disease,
           d.department_name, c.number,
           CASE WHEN last_t.id IS NULL THEN 'Не размещена'
                WHEN last_t.chamber_id IS NULL THEN 'Выписана'
                WHEN d.kind = 'operating' THEN 'В операционной'
                ELSE 'В палате' END AS patient_status,
           (last_t.id IS NOT NULL AND last_t.chamber_id IS NULL) AS discharged, d.kind, COALESCE(last_t.id,0)
    FROM patient p
    LEFT JOIN LATERAL (
        SELECT t.id, t.chamber_id FROM transfer t
        WHERE t.patient_id = p.id ORDER BY t.id DESC LIMIT 1
    ) last_t ON TRUE
    LEFT JOIN chamber c ON c.id = last_t.chamber_id
    LEFT JOIN department d ON d.id = c.department_id
)SQL";
}

Yadro::Yadro(QObject *parent) : QObject(parent) {}

QString Yadro::connectToDatabase(const QString &host, int port, const QString &dbName,
                                 const QString &user, const QString &password)
{
    logoutUser();
    if (s_db.isValid() && s_db.isOpen()) s_db.close();
    if (port < 1 || port > 65535 || host.trimmed().isEmpty() || dbName.trimmed().isEmpty() || user.trimmed().isEmpty()) {
        s_connectionError = QStringLiteral("Проверьте адрес, порт, базу и пользователя в параметрах запуска.");
        return s_connectionError;
    }
    if (!s_db.isValid()) s_db = QSqlDatabase::addDatabase("QPSQL", "perinatal_connection");
    s_db.setHostName(host);
    s_db.setPort(port);
    s_db.setDatabaseName(dbName);
    s_db.setUserName(user);

    s_db.setConnectOptions("connect_timeout=5");
    if (!s_db.open(user,password)) {
        qWarning().noquote() << "PostgreSQL:" << s_db.lastError().text();
        s_connectionError = QStringLiteral("Нет связи с PostgreSQL. Проверьте параметры запуска и доступность сервера.");
        return s_connectionError;
    }
    s_connectionError.clear();
    return QString();
}

QString Yadro::databaseStatus() const
{
    if (ready()) return QString();
    return s_connectionError.isEmpty() ? QStringLiteral("Данные не актуальны. Нет подключения к базе данных.") : s_connectionError;
}

bool Yadro::ready() const { return s_db.isValid() && s_db.isOpen(); }
bool Yadro::active() const {
    if (!ready() || m_employeeId <= 0) return false;
    QSqlQuery q(s_db);
    q.prepare("SELECT 1 FROM employee e JOIN role r ON r.id=e.role_id "
              "WHERE e.id=:id AND e.block=FALSE AND r.role_name=:role");
    q.bindValue(":id",m_employeeId);
    q.bindValue(":role",m_role);
    return q.exec() && q.next();
}
bool Yadro::admin() const { return m_role == QStringLiteral("Администратор") && active(); }
bool Yadro::head() const { return m_role == QStringLiteral("Заведующая отделением") && active(); }
bool Yadro::clinician() const { return head() || (m_role == QStringLiteral("Врач акушер-гинеколог") && active()); }
bool Yadro::canRegister() const { return head() || (m_role == QStringLiteral("Медсестра") && active()); }

// Фиксируем полномочия до COMMIT. Изменение роли или блокировка ждёт завершения операции.
bool Yadro::beginWrite()
{
    if (!s_db.transaction()) return false;
    QSqlQuery session(s_db);
    session.prepare("SELECT e.id FROM employee e JOIN role r ON r.id=e.role_id "
                    "WHERE e.id=:id AND NOT e.block AND r.role_name=:role FOR SHARE OF e");
    session.bindValue(":id", m_employeeId);
    session.bindValue(":role", m_role);
    if (session.exec() && session.next()) return true;
    s_db.rollback();
    return false;
}
QString Yadro::roleError() const
{
    if (!ready()) return databaseStatus();
    QSqlQuery probe(s_db);
    return probe.exec("SELECT 1") ? QStringLiteral("Недостаточно прав для выполнения действия.")
                                  : QStringLiteral("Данные не актуальны. Нет связи с сервером.");
}
void Yadro::setReadError(const QString &message)
{
    if (m_readError == message) return;
    m_readError = message;
    emit readErrorChanged();
}
void Yadro::logoutUser() { setReadError({}); m_employeeId = -1; m_role.clear(); }

QString Yadro::loginUser(const QString &login, const QString &password)
{
    logoutUser();
    if (!ready()) return databaseStatus();
    if (password.toUtf8().size() > 72) return QStringLiteral("Неверный логин или пароль.");
    if (clean(login).isEmpty() || password.isEmpty()) return QStringLiteral("Введите логин и пароль.");
    QSqlQuery q(s_db);
    q.prepare(R"SQL(
       SELECT e.id, e.name, e.sour_name, e.block, r.role_name,
              (a.password = crypt(:password, a.password)) AS correct_password
       FROM authorizations a JOIN employee e ON e.id = a.employee_id
       JOIN role r ON r.id = e.role_id WHERE a.login = :login
    )SQL");
    q.bindValue(":login", clean(login));
    q.bindValue(":password", password);
    if (!q.exec()) return dbError(QStringLiteral("авторизация"), q);
    if (!q.next() || !q.value(5).toBool()) return QStringLiteral("Неверный логин или пароль.");
    if (q.value(3).toBool()) return QStringLiteral("Учётная запись заблокирована. Обратитесь к администратору.");
    const QString role = q.value(4).toString();
    if (!QStringList{"Администратор", "Медсестра", "Врач акушер-гинеколог", "Заведующая отделением"}.contains(role))
        return QStringLiteral("Роль сотрудника не настроена.");
    m_employeeId = q.value(0).toInt();
    m_role = q.value(4).toString();
    if (!audit(QStringLiteral("LOGIN"), QStringLiteral("employee"), m_employeeId)) {
        logoutUser();
        return QStringLiteral("Ошибка журнала аудита. Проверьте обновление схемы базы данных.");
    }
    return q.value(2).toString() + " " + q.value(1).toString() + "|" + m_role;
}

QString Yadro::generatePassword() const
{
    // Пароль создаётся из криптографически случайных байтов Qt, без встроенных паролей.
    static const QString alphabet = QStringLiteral("ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#");
    QString password;
    auto *rng = QRandomGenerator::system();
    for (int i = 0; i < 16; ++i) password += alphabet.at(rng->bounded(int(alphabet.size())));
    return password;
}

bool Yadro::audit(const QString &action, const QString &target, int targetId)
{
    if (!ready() || m_employeeId <= 0) return false;
    QSqlQuery q(s_db);
    q.prepare("INSERT INTO audit_event (employee_id, action, target, target_id) "
              "VALUES (:emp, :action, :target, :id)");
    q.bindValue(":emp", m_employeeId);
    q.bindValue(":action", action);
    q.bindValue(":target", target);
    q.bindValue(":id", targetId);
    if (!q.exec()) { qWarning() << "Ошибка записи аудита:" << q.lastError().nativeErrorCode(); return false; }
    return true;
}

QVariantList Yadro::getRoles()
{
    QVariantList out;
    if (!admin()) {setReadError(roleError()); return out;}
    QSqlQuery q(s_db);
    if (!q.exec("SELECT id, role_name FROM role ORDER BY id")) { setReadError(dbError("роли",q));return out; }
    while (q.next()) out.append(QVariantMap{{"id",q.value(0).toInt()},{"name",q.value(1).toString()}});
    setReadError({});
    return out;
}

QVariantList Yadro::getEmployees()
{
    QVariantList out;
    if (!admin()) {setReadError(roleError()); return out;}
    QSqlQuery q(s_db);
    if (!q.exec(R"SQL(
       SELECT e.id, e.name, e.sour_name, a.login, r.role_name, e.role_id, e.block
       FROM employee e LEFT JOIN authorizations a ON a.employee_id = e.id
       LEFT JOIN role r ON r.id = e.role_id ORDER BY e.id
    )SQL")) { setReadError(dbError("сотрудники",q));return out; }
    while (q.next()) {
        QVariantMap m{{"id",q.value(0).toString()},{"name",q.value(1).toString()},
          {"sour_name",q.value(2).toString()},
          {"full_name",q.value(2).toString() + " " + q.value(1).toString()},
          {"login",q.value(3).toString()}, {"password",QString()}, // Никогда не выдаём хеш пароля интерфейсу!
          {"role",q.value(4).toString()},{"role_id",q.value(5).toInt()},
          {"block",q.value(6).toBool()}};
        out.append(m);
    }
    setReadError({});
    return out;
}

QString Yadro::createEmployee(const QString &name, const QString &sourName, const QString &login,
                              const QString &password, int roleId)
{
    if (!admin()) return roleError();
    if (password.toUtf8().size() > 72) return QStringLiteral("Пароль превышает 72 байта UTF-8.");
    if (clean(name).isEmpty() || clean(sourName).isEmpty() || clean(login).isEmpty() || password.size() < 10 || roleId <= 0)
        return QStringLiteral("Укажите ФИО, уникальный логин, роль и пароль не короче 10 символов.");
    if (!validNewLogin(login)) return QStringLiteral("Введите электронную почту или номер телефона.");
    if (!beginWrite()) return QStringLiteral("Не удалось начать транзакцию.");
    QSqlQuery q(s_db);
    q.prepare("INSERT INTO employee (name, sour_name, role_id, block) VALUES (:n,:s,:r,FALSE) RETURNING id");
    q.bindValue(":n", clean(name)); q.bindValue(":s", clean(sourName)); q.bindValue(":r",roleId);
    if (!q.exec() || !q.next()) { const QString e=dbError("создание сотрудника",q); s_db.rollback();return e; }
    const int id=q.value(0).toInt();
    q.prepare("INSERT INTO authorizations (employee_id, login, password) VALUES (:e,:l,crypt(:p, gen_salt('bf', 12)))");
    q.bindValue(":e",id); q.bindValue(":l",clean(login)); q.bindValue(":p",password);
    if (!q.exec()) { const bool duplicate=isUniqueError(q); s_db.rollback(); return duplicate ? QStringLiteral("Логин уже занят.") : dbError("учётная запись",q); }
    if (!audit("EMPLOYEE_CREATED","employee",id)) {s_db.rollback();return QStringLiteral("Не удалось записать событие аудита.");}
    if (!s_db.commit()) {s_db.rollback(); return QStringLiteral("Не удалось сохранить сотрудника.");}
    return QString();
}

QString Yadro::updateEmployee(int id, const QString &name, const QString &sourName,
                              const QString &login, const QString &password, int roleId)
{
    if (!admin()) return roleError();
    if (id <= 0 || clean(name).isEmpty() || clean(sourName).isEmpty() || clean(login).isEmpty() || roleId <= 0)
        return QStringLiteral("Заполните обязательные поля.");
    if (password.toUtf8().size() > 72) return QStringLiteral("Пароль превышает 72 байта UTF-8.");
    if (!password.isEmpty() && password.size() < 10) return QStringLiteral("Новый пароль должен содержать не меньше 10 символов.");
    if (!beginWrite()) return QStringLiteral("Не удалось начать транзакцию.");
    QSqlQuery q(s_db);
    if (!validNewLogin(login)) {
        q.prepare("SELECT id FROM authorizations WHERE employee_id=:id AND login=:login FOR UPDATE");
        q.bindValue(":id",id);
        q.bindValue(":login",clean(login));
        if (!q.exec() || !q.next()) {
            s_db.rollback();
            return QStringLiteral("Для нового логина укажите электронную почту или номер телефона.");
        }
    }
    if (id == m_employeeId) {
        q.prepare("SELECT id FROM role WHERE id=:id AND role_name='Администратор'");
        q.bindValue(":id", roleId);
        if (!q.exec() || !q.next()) { s_db.rollback(); return QStringLiteral("Нельзя снять собственные права администратора."); }
    }
    q.prepare("UPDATE employee SET name=:n, sour_name=:s, role_id=:r WHERE id=:id");
    q.bindValue(":n",clean(name));q.bindValue(":s",clean(sourName));q.bindValue(":r",roleId);q.bindValue(":id",id);
    if (!q.exec() || q.numRowsAffected()!=1) { const QString e=dbError("редактирование сотрудника",q);s_db.rollback();return e; }
    if (password.isEmpty()) {
        q.prepare("UPDATE authorizations SET login=:l WHERE employee_id=:id");
    } else {
        q.prepare("UPDATE authorizations SET login=:l, password=crypt(:p,gen_salt('bf',12)) WHERE employee_id=:id");
        q.bindValue(":p",password);
    }
    q.bindValue(":l",clean(login));q.bindValue(":id",id);
    if (!q.exec() || q.numRowsAffected()!=1) {
        const bool duplicate=isUniqueError(q); const QString e=dbError("логин сотрудника",q);s_db.rollback();
        return duplicate ? QStringLiteral("Логин уже занят.") : e;
    }
    if (!audit("EMPLOYEE_UPDATED","employee",id)) {s_db.rollback();return QStringLiteral("Ошибка журнала действий.");}
    if (!s_db.commit()) {s_db.rollback();return QStringLiteral("Не удалось сохранить изменения.");}
    return QString();
}

QString Yadro::setEmployeeBlocked(int id, bool blocked)
{
    if (!admin()) return roleError();
    if (id == m_employeeId && blocked) return QStringLiteral("Нельзя заблокировать собственную учётную запись.");
    if (!beginWrite()) return QStringLiteral("Ошибка начала транзакции.");
    QSqlQuery q(s_db);
    q.prepare("UPDATE employee SET block=:blocked WHERE id=:id");
    q.bindValue(":blocked",blocked); q.bindValue(":id",id);
    if (!q.exec() || q.numRowsAffected()!=1 || !audit(blocked?"EMPLOYEE_BLOCKED":"EMPLOYEE_UNBLOCKED","employee",id)
        || !s_db.commit()) { s_db.rollback();return QStringLiteral("Не удалось изменить блокировку сотрудника."); }
    return QString();
}

QString Yadro::deleteEmployee(int id)
{
    // Сотрудников с сохранённой историей нельзя удалять физически.
    return setEmployeeBlocked(id, true);
}

QVariantList Yadro::getDepartments()
{
    QVariantList out;
    if (!active()) {setReadError(roleError()); return out;}
    QSqlQuery q(s_db);
    if (!q.exec(R"SQL(
       SELECT d.id, d.department_name, count(c.id) AS count_all,
              count(c.id) FILTER (WHERE c.disease) AS count_isolation, d.kind, COALESCE(SUM(c.capacity-c.current_load),0)
       FROM department d LEFT JOIN chamber c ON c.department_id=d.id
       GROUP BY d.id, d.department_name,d.kind ORDER BY d.id
    )SQL")) {setReadError(dbError("отделения",q));return out;}
    while(q.next())out.append(QVariantMap{{"id",q.value(0).toString()},{"name",q.value(1).toString()},
      {"capacity",q.value(2).toInt()},{"capacity_disease",q.value(3).toInt()},{"kind",q.value(4).toString()},{"free_places",q.value(5).toInt()}});
    setReadError({});
    return out;
}

QString Yadro::createDepartment(const QString &name, int capacity, int capacityDisease, const QVariantList &chambers)
{
    if (!admin())return roleError();
    if (clean(name).isEmpty())return QStringLiteral("Введите название отделения.");
    if (!beginWrite())return QStringLiteral("Ошибка начала транзакции.");
    QSqlQuery q(s_db);
    q.prepare("INSERT INTO department (department_name,chamber_capacity,chamber_capacity_disease) VALUES (:n,:c,:d) RETURNING id");
    q.bindValue(":n",clean(name));q.bindValue(":c",std::max(0,capacity));q.bindValue(":d",std::max(0,capacityDisease));
    if (!q.exec() || !q.next()) {const bool duplicate=isUniqueError(q);s_db.rollback();return duplicate?QStringLiteral("Название отделения уже занято."):dbError("отделение",q);}
    const int id=q.value(0).toInt();
    for(const QVariant &v:chambers){
        const QVariantMap c=v.toMap();
        const int number=c.value("number").toInt(),beds=c.value("capacity").toInt();
        if(number<=0 || beds<=0){s_db.rollback();return QStringLiteral("Номер и вместимость палаты должны быть положительными.");}
        q.prepare("INSERT INTO chamber(number,capacity,department_id,disease,current_load) VALUES (:n,:c,:d,:s,0)");
        q.bindValue(":n",number);q.bindValue(":c",beds);q.bindValue(":d",id);q.bindValue(":s",c.value("disease").toBool());
        if(!q.exec()){const bool duplicate=isUniqueError(q);s_db.rollback();return duplicate?QStringLiteral("Повторяется номер палаты."):dbError("добавление палаты",q);}
    }
    if(!audit("DEPARTMENT_CREATED","department",id) || !s_db.commit()){s_db.rollback();return QStringLiteral("Не удалось создать отделение.");}
    return QString();
}

QString Yadro::updateDepartmentName(int id, const QString &name)
{
    if(!admin())return roleError();
    if(clean(name).isEmpty())return QStringLiteral("Введите название отделения.");
    if(!beginWrite())return roleError();
    QSqlQuery q(s_db);q.prepare("UPDATE department SET department_name=:n WHERE id=:id");
    q.bindValue(":n",clean(name));q.bindValue(":id",id);
    if(!q.exec() || q.numRowsAffected()!=1){s_db.rollback();return dbError("название отделения",q);}
    if(!audit("DEPARTMENT_UPDATED","department",id) || !s_db.commit()){s_db.rollback();return QStringLiteral("Сохранение не подтверждено.");}
    return QString();
}

QString Yadro::deleteDepartment(int id)
{
    if(!admin())return roleError();
    if(!beginWrite())return QStringLiteral("Ошибка начала транзакции.");
    QSqlQuery q(s_db);
    q.prepare("DELETE FROM chamber WHERE department_id=:id");q.bindValue(":id",id);
    if(!q.exec()){s_db.rollback();return QStringLiteral("Нельзя удалить отделение: в палатах есть история переводов. Сохраните отделение для аудита.");}
    q.prepare("DELETE FROM department WHERE id=:id");q.bindValue(":id",id);
    if(!q.exec() || q.numRowsAffected()!=1){s_db.rollback();return dbError("удаление отделения",q);}
    if(!audit("DEPARTMENT_DELETED","department",id) || !s_db.commit()){s_db.rollback();return QStringLiteral("Не удалось удалить отделение.");}
    return QString();
}

QVariantList Yadro::getChambersByDepartment(int departmentId)
{
    QVariantList out;
    if (!active()){setReadError(roleError()); return out;}
    // Считаем места по последнему событию каждой пациентки, не по потенциально устаревшему current_load.
    QSqlQuery q(s_db);
    q.prepare(R"SQL(
       WITH latest AS (
           SELECT DISTINCT ON (patient_id) patient_id,chamber_id
           FROM transfer ORDER BY patient_id,id DESC
       ), loads AS (
           SELECT chamber_id, COUNT(*)::integer AS occupied FROM latest
           WHERE chamber_id IS NOT NULL GROUP BY chamber_id
       )
       SELECT c.number,c.capacity,c.disease,
              GREATEST(0,c.capacity-COALESCE(l.occupied,0)) AS free_places,
              COALESCE(l.occupied,0) AS current_load,c.id, d.kind
       FROM chamber c JOIN department d ON d.id=c.department_id LEFT JOIN loads l ON l.chamber_id=c.id
       WHERE c.department_id=:dept ORDER BY c.number
    )SQL");
    q.bindValue(":dept",departmentId);
    if(!q.exec()){setReadError(dbError("палаты",q));return out;}
    while(q.next())out.append(QVariantMap{{"number",q.value(0).toInt()},{"capacity",q.value(1).toInt()},
      {"disease",q.value(2).toBool()},{"free_places",q.value(3).toInt()},
      {"current_load",q.value(4).toInt()},{"id",q.value(5).toInt()},{"kind",q.value(6).toString()}});
    setReadError({});
    return out;
}

bool Yadro::chamberExists(int departmentId, int number)
{
    if(!admin())return false;
    QSqlQuery q(s_db);q.prepare("SELECT 1 FROM chamber WHERE department_id=:d AND number=:n");
    q.bindValue(":d",departmentId);q.bindValue(":n",number);
    return q.exec() && q.next();
}

QString Yadro::addChamber(int departmentId, int number, int capacity, bool isDisease)
{
    if(!admin())return roleError();
    if(number<=0 || capacity<=0)return QStringLiteral("Номер и вместимость должны быть положительными.");
    if(!beginWrite())return roleError();
    QSqlQuery q(s_db);
    q.prepare("INSERT INTO chamber(number,capacity,department_id,disease,current_load) "
              "SELECT :n,:c,id,:s,0 FROM department WHERE id=:d AND (kind <> 'operating' OR CAST(:beds AS integer)=1) RETURNING id");
    q.bindValue(":beds",capacity);
    q.bindValue(":n",number);q.bindValue(":c",capacity);q.bindValue(":d",departmentId);q.bindValue(":s",isDisease);
    if(!q.exec()){s_db.rollback();return isUniqueError(q)?QStringLiteral("Палата уже существует."):dbError("добавление палаты",q);}
    if(!q.next()){s_db.rollback();return QStringLiteral("Проверьте отделение. Для операционной требуется одно место.");}
    if(!audit("CHAMBER_CREATED","chamber",q.value(0).toInt()) || !s_db.commit()){s_db.rollback();return QStringLiteral("Сохранение не подтверждено.");}
    return QString();
}

QString Yadro::deleteChamberByNumber(int departmentId, int number)
{
    if(!admin())return roleError();
    if(!beginWrite())return roleError();
    QSqlQuery q(s_db);q.prepare("DELETE FROM chamber WHERE department_id=:d AND number=:n");
    q.bindValue(":d",departmentId);q.bindValue(":n",number);
    if(!q.exec()){s_db.rollback();return QStringLiteral("Нельзя удалить палату: она используется в истории переводов.");}
    if(q.numRowsAffected()!=1){s_db.rollback();return QStringLiteral("Палата не найдена.");}
    if(!audit("CHAMBER_DELETED","department",departmentId) || !s_db.commit()){s_db.rollback();return QStringLiteral("Сохранение не подтверждено.");}
    return QString();
}

QVariantList Yadro::getPatients()
{
    QVariantList out;
    if(!(canRegister() || clinician())){setReadError(roleError()); return out;}
    QSqlQuery q(s_db);
    if(!q.exec(QString::fromUtf8(lastPlacementSql)+" ORDER BY p.id")){setReadError(dbError("пациентки",q));return out;}
    while(q.next())out.append(patientRow(q));
    setReadError({});
    return out;
}

QVariantList Yadro::getPatientsByChamber(int departmentId, int chamberNumber)
{
    QVariantList out;
    if(!(canRegister() || clinician())){setReadError(roleError()); return out;}
    QSqlQuery q(s_db);
    q.prepare(QString::fromUtf8(lastPlacementSql)+R"SQL(
        WHERE c.department_id=:dept AND c.number=:number ORDER BY p.id
    )SQL");
    q.bindValue(":dept",departmentId);q.bindValue(":number",chamberNumber);
    if(!q.exec()){setReadError(dbError("пациентки палаты",q));return out;}
    while(q.next())out.append(patientRow(q));
    setReadError({});
    return out;
}

QVariantList Yadro::getTransfers()
{
    QVariantList out;
    if(!clinician()){setReadError(roleError()); return out;}
    QSqlQuery q(s_db);
    if(!q.exec(R"SQL(
       SELECT t.id,t.patient_id,t.employee_id,t.chamber_id,t.date
       FROM transfer t ORDER BY t.id DESC
    )SQL")){setReadError(dbError("история переводов",q));return out;}
    while(q.next())out.append(QVariantMap{{"id",q.value(0).toInt()},{"patient_id",q.value(1).toInt()},
       {"employee_id",q.value(2).toInt()},{"chamber_id",q.value(3).toInt()},
       {"date",q.value(4).toDateTime().toString("yyyy.MM.dd HH:mm")}});
    setReadError({});
    return out;
}

QVariantList Yadro::getPatientHistory(int patientId)
{
    QVariantList out;
    if(!clinician()){setReadError(roleError()); return out;}
    QSqlQuery q(s_db);
    q.prepare(R"SQL(
       SELECT t.id, t.date, d.department_name, c.number,
              e.sour_name || ' ' || e.name AS employee_name, t.chamber_id,
              p.discharge_recommendations, p.discharge_date::date
       FROM transfer t JOIN patient p ON p.id=t.patient_id
       LEFT JOIN chamber c ON c.id=t.chamber_id
       LEFT JOIN department d ON d.id=c.department_id
       LEFT JOIN employee e ON e.id=t.employee_id
       WHERE t.patient_id=:id ORDER BY t.id DESC
    )SQL");
    q.bindValue(":id",patientId);
    if(!q.exec()){setReadError(dbError("история пациентки",q));return out;}
    while(q.next())out.append(QVariantMap{{"id",q.value(0).toInt()},
       {"date",q.value(1).toDateTime().toString("yyyy.MM.dd HH:mm")},
       {"department",q.value(2).toString()}, {"chamber",q.value(3).toString()},
       {"employee",q.value(4).toString()},
       {"action",q.value(5).isNull()?QStringLiteral("Выписка"):QStringLiteral("Размещение / перевод")},
       {"effectiveDate",q.value(5).isNull()?q.value(7).toDate().toString(Qt::ISODate):QString()},
       {"recommendations",q.value(5).isNull()?q.value(6).toString():QString()}});
    setReadError({});
    return out;
}

QVariantList Yadro::getOccupancyStatistics()
{
    QVariantList out;
    if(!clinician()){setReadError(roleError()); return out;}
    QSqlQuery q(s_db);
    if(!q.exec(R"SQL(
       WITH latest AS (SELECT DISTINCT ON(patient_id) chamber_id FROM transfer ORDER BY patient_id,id DESC),
       load AS (SELECT chamber_id,count(*)::integer AS num FROM latest WHERE chamber_id IS NOT NULL GROUP BY chamber_id)
       SELECT d.id,d.department_name,COALESCE(sum(c.capacity),0)::integer AS capacity,
              COALESCE(sum(l.num),0)::integer AS occupied
       FROM department d LEFT JOIN chamber c ON c.department_id=d.id
       LEFT JOIN load l ON l.chamber_id=c.id
       GROUP BY d.id,d.department_name ORDER BY d.id
    )SQL")){setReadError(dbError("статистика",q));return out;}
    while(q.next()){
       int capacity=q.value(2).toInt(),occupied=q.value(3).toInt();
       out.append(QVariantMap{{"id",q.value(0).toInt()},{"name",q.value(1).toString()},
         {"capacity",capacity},{"occupied",occupied},{"free_places",std::max(0,capacity-occupied)},
         {"percent",capacity?int(100.0*occupied/capacity+0.5):0}});
    }
    setReadError({});
    return out;
}

QString Yadro::createPatient(const QString &name, const QString &sourName, const QString &policy,
                             const QString &pregnancyPeriod, bool isDisease)
{
    if(!canRegister())return roleError();
    static const QRegularExpression policyReg("^[0-9]{16}$");
    if(clean(name).isEmpty()||clean(sourName).isEmpty()||!policyReg.match(clean(policy)).hasMatch())
       return QStringLiteral("Укажите имя, фамилию и полис ОМС из 16 цифр.");
    bool ok=false;
    int weeks=clean(pregnancyPeriod).toInt(&ok);
    if(!ok || weeks<0 || weeks>45)return QStringLiteral("Срок беременности должен быть от 0 до 45 недель.");
    if(!beginWrite())return QStringLiteral("Не удалось начать транзакцию.");
    QSqlQuery q(s_db);
    q.prepare("INSERT INTO patient(name,sour_name,policy,pregnancy_period,disease) VALUES (:n,:s,:p,:w,:d) RETURNING id");
    q.bindValue(":n",clean(name));q.bindValue(":s",clean(sourName));q.bindValue(":p",clean(policy));
    q.bindValue(":w",QString::number(weeks));q.bindValue(":d",isDisease);
    if(!q.exec() || !q.next()){
        const bool duplicate=isUniqueError(q);const QString e=dbError("регистрация пациентки",q);s_db.rollback();
        return duplicate?QStringLiteral("Пациентка с таким номером полиса уже зарегистрирована."):e;
    }
    const int id=q.value(0).toInt();
    if(!audit("PATIENT_CREATED","patient",id)||!s_db.commit()) {s_db.rollback();return QStringLiteral("Не удалось сохранить пациентку.");}
    return QString();
}

int Yadro::actualLoad(int chamberId, bool *ok)
{
    QSqlQuery q(s_db);
    q.prepare(R"SQL(
       SELECT COUNT(*) FROM (
          SELECT DISTINCT ON (patient_id) chamber_id FROM transfer
          ORDER BY patient_id,id DESC
       ) current_places WHERE chamber_id=:ch
    )SQL");
    q.bindValue(":ch",chamberId);
    const bool success=q.exec() && q.next();
    if(ok)*ok=success;
    if(!success){dbError("подсчёт загруженности",q);return -1;}
    return q.value(0).toInt();
}

bool Yadro::updateLoad(int chamberId, int value)
{
    QSqlQuery q(s_db);
    q.prepare("UPDATE chamber SET current_load=:load WHERE id=:id");
    q.bindValue(":load",value);q.bindValue(":id",chamberId);
    if(!q.exec()){dbError("занятость палаты",q);return false;}
    return q.numRowsAffected()==1;
}

QString Yadro::transferPatient(int patientId, int departmentId, int chamberNumber, int expectedVersion)
{
    if(!clinician())return roleError();
    if(patientId<=0||departmentId<=0||chamberNumber<=0)return QStringLiteral("Неверно выбрана пациентка или палата.");
    if(!beginWrite())return QStringLiteral("Не удалось начать транзакцию.");
    auto fail=[this](const QString &message){s_db.rollback();return message;};
    QSqlQuery q(s_db);
    q.prepare("SELECT disease FROM patient WHERE id=:id FOR UPDATE");q.bindValue(":id",patientId);
    if(!q.exec())return fail(dbError("поиск пациентки",q));
    if(!q.next())return fail(QStringLiteral("Пациентка не найдена."));
    const bool sick=q.value(0).toBool();

    // ID, а не время события: NULL в старом поле date мог ошибочно становиться 'последним' при DESC.
    q.prepare("SELECT id,chamber_id FROM transfer WHERE patient_id=:id ORDER BY id DESC LIMIT 1");
    q.bindValue(":id",patientId);
    int version=0;
    int oldId=-1;
    if(!q.exec())return fail(dbError("текущее размещение",q));
    if(q.next()){
        if(q.value(1).isNull())return fail(QStringLiteral("Пациентка выписана. Повторное размещение требует нового случая госпитализации."));
        oldId=q.value(1).toInt();
        version=q.value(0).toInt();
    }
    if(expectedVersion >= 0 && version != expectedVersion) return fail(QStringLiteral("Размещение уже изменено. Обновите список и откройте перевод заново."));
    q.prepare("SELECT id FROM chamber WHERE department_id=:dept AND number=:number");
    q.bindValue(":dept",departmentId);q.bindValue(":number",chamberNumber);
    if(!q.exec())return fail(dbError("поиск палаты",q));
    if(!q.next())return fail(QStringLiteral("Выбранная палата не найдена."));
    const int newId=q.value(0).toInt();
    if(oldId==newId)return fail(QStringLiteral("Пациентка уже находится в выбранной палате."));

    // Фиксированный порядок блокировки предотвращает взаимные deadlock при параллельных переводах.
    q.prepare("SELECT c.id,c.capacity,c.disease,d.kind FROM chamber c JOIN department d ON d.id=c.department_id WHERE c.id=:new OR c.id=:old ORDER BY c.id FOR UPDATE OF c");
    q.bindValue(":new",newId);q.bindValue(":old",oldId);
    if(!q.exec())return fail(dbError("блокировка палат",q));
    bool operating=false; int newCap=0;bool newSick=false;bool found=false;bool oldFound=(oldId<0);
    while(q.next()){
        int id=q.value(0).toInt();
        if(id==newId){found=true;newCap=q.value(1).toInt();newSick=q.value(2).toBool(); operating=q.value(3).toString()=="operating";}
        if(id==oldId)oldFound=true;
    }
    if(!found||!oldFound)return fail(QStringLiteral("Исходная или целевая палата больше не существует."));
    if(operating && newCap != 1)return fail(QStringLiteral("Вместимость операционной должна быть равна одному месту."));
    if(!operating && sick!=newSick)return fail(sick ? QStringLiteral("Для пациентки требуется палата-изолятор.")
                                        : QStringLiteral("Для пациентки выберите обычную палату."));
    bool ok=false;
    const int targetLoad=actualLoad(newId,&ok);
    if(!ok)return fail(QStringLiteral("Не удалось проверить занятость палаты."));
    if(targetLoad>=newCap)return fail(QStringLiteral("В палате больше нет свободных мест."));
    int priorLoad=0;
    if(oldId>=0){
        priorLoad=actualLoad(oldId,&ok);
        if(!ok||priorLoad<1)return fail(QStringLiteral("Ошибка целостности исходного размещения. Выполните сверку базы."));
    }
    q.prepare("INSERT INTO transfer (patient_id,employee_id,chamber_id,date) VALUES (:p,:e,:c,CURRENT_TIMESTAMP)");
    q.bindValue(":p",patientId);q.bindValue(":e",m_employeeId);q.bindValue(":c",newId);
    if(!q.exec())return fail(dbError("сохранение перевода",q));
    if(oldId>=0 && !updateLoad(oldId,priorLoad-1))return fail(QStringLiteral("Не удалось освободить старую палату."));
    if(!updateLoad(newId,targetLoad+1))return fail(QStringLiteral("Не удалось занять новую палату."));
    if(!audit("PATIENT_TRANSFERRED","patient",patientId))return fail(QStringLiteral("Не удалось записать событие аудита."));
    if(!s_db.commit()){s_db.rollback();return QStringLiteral("Сервер не подтвердил перевод. Попробуйте обновить данные.");}
    return QString();
}

QString Yadro::dischargePatient(int patientId, const QString &recommendations, const QString &date, int expectedVersion)
{
    if(!head())return roleError();
    if(patientId<=0)return QStringLiteral("Пациентка не выбрана.");
    if(!beginWrite())return QStringLiteral("Не удалось начать транзакцию.");
    auto fail=[this](const QString &message){s_db.rollback();return message;};
    QSqlQuery q(s_db);
    q.prepare("SELECT id FROM patient WHERE id=:id FOR UPDATE");q.bindValue(":id",patientId);
    if(!q.exec())return fail(dbError("поиск пациентки",q));
    if(!q.next())return fail(QStringLiteral("Пациентка не найдена."));
    q.prepare(R"SQL(
      SELECT t.chamber_id,d.kind,t.date::date,t.id
      FROM transfer t LEFT JOIN chamber c ON c.id=t.chamber_id
      LEFT JOIN department d ON d.id=c.department_id
      WHERE t.patient_id=:id ORDER BY t.id DESC LIMIT 1
    )SQL");
    q.bindValue(":id",patientId);
    if(!q.exec())return fail(dbError("проверка размещения",q));
    if(!q.next()||q.value(0).isNull())return fail(QStringLiteral("Пациентка уже выписана или ещё не размещена."));
    if(expectedVersion >= 0 && expectedVersion != q.value(3).toInt()) return fail(QStringLiteral("Размещение изменилось. Проверьте карту перед выпиской."));
    const int chamberId=q.value(0).toInt();
    const QString department=q.value(1).toString();
    if(department != "postpartum")
        return fail(QStringLiteral("Выписка возможна только из послеродового отделения."));
    const QDate chosen = QDate::fromString(date, Qt::ISODate);
    const QDate placed = q.value(2).toDate();
    if (!chosen.isValid() || chosen < placed || clean(recommendations).isEmpty())
        return fail(QStringLiteral("Укажите рекомендации и дату не раньше последнего размещения."));
    q.prepare("SELECT CAST(:day AS date) <= CURRENT_DATE");
    q.bindValue(":day", chosen);
    if (!q.exec() || !q.next() || !q.value(0).toBool())
        return fail(QStringLiteral("Проверьте дату выписки: будущая дата недопустима."));
    q.prepare("SELECT id FROM chamber WHERE id=:id FOR UPDATE");q.bindValue(":id",chamberId);
    if(!q.exec())return fail(dbError("блокировка палаты",q));
    if(!q.next())return fail(QStringLiteral("Палата пациентки недоступна."));
    bool ok=false;const int oldLoad=actualLoad(chamberId,&ok);
    if(!ok||oldLoad<=0)return fail(QStringLiteral("Некорректное состояние загруженности палаты."));
    q.prepare("INSERT INTO transfer(patient_id,employee_id,chamber_id,date) VALUES (:p,:e,NULL,CURRENT_TIMESTAMP)");
    q.bindValue(":p",patientId);q.bindValue(":e",m_employeeId);
    if(!q.exec())return fail(dbError("запись выписки",q));
    q.prepare("UPDATE patient SET discharge_date=CAST(:day AS date) + LOCALTIME, discharge_recommendations=:r WHERE id=:id");
    q.bindValue(":day",chosen);q.bindValue(":r",clean(recommendations));q.bindValue(":id",patientId);
    if(!q.exec() || q.numRowsAffected()!=1)return fail(dbError("рекомендации при выписке",q));
    if(!updateLoad(chamberId,oldLoad-1))return fail(QStringLiteral("Не удалось освободить место."));
    if(!audit("PATIENT_DISCHARGED","patient",patientId))return fail(QStringLiteral("Не удалось сохранить событие выписки."));
    if(!s_db.commit()){s_db.rollback();return QStringLiteral("Сохранение выписки не подтверждено.");}
    return QString();
}
