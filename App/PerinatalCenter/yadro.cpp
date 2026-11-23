#include "yadro.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

QSqlDatabase Yadro::s_db;

Yadro::Yadro(QObject *parent) : QObject(parent) {}

QString Yadro::connectToDatabase(const QString &host, int port, const QString &dbName, const QString &user, const QString &password)
{
    if (s_db.isOpen()) s_db.close();
    s_db = QSqlDatabase::addDatabase("QPSQL");
    s_db.setHostName(host);
    s_db.setPort(port);
    s_db.setDatabaseName(dbName);
    s_db.setUserName(user);
    s_db.setPassword(password);
    s_db.setConnectOptions("connect_timeout=3");
    if (!s_db.open()) return QStringLiteral("Ошибка подключения: %1").arg(s_db.lastError().text());
    return QString();
}

QString Yadro::loginUser(const QString &login, const QString &password)
{
    if (login.trimmed().isEmpty() || password.isEmpty())
        return QStringLiteral("Введите логин и пароль.");

    if (login == "admin" && password == "admin")
        return QStringLiteral("Администратор|Администратор");

    if (!s_db.isOpen())
        return QStringLiteral("Нет подключения к базе данных.");

    QSqlQuery query(s_db);
    query.prepare("SELECT e.name, e.sour_name, e.block, r.role_name "
                  "FROM authorizations a "
                  "JOIN employee e ON a.employee_id = e.id "
                  "LEFT JOIN role r ON e.role_id = r.id "
                  "WHERE a.login = :login AND a.password = :password");
    query.bindValue(":login", login);
    query.bindValue(":password", password);

    if (!query.exec())
        return QStringLiteral("Ошибка БД: %1").arg(query.lastError().text());

    if (query.next()) {
        bool isBlocked = query.value(2).toBool();
        if (isBlocked) {
            return QStringLiteral("Пользователь заблокирован. Обратитесь к администратору.");
        }

        QString name = query.value(0).toString();
        QString sourName = query.value(1).toString();
        QString roleName = query.value(3).toString();

        return sourName + " " + name + "|" + roleName;
    }

    return QStringLiteral("Неверный логин или пароль.");
}

// ==================== СОТРУДНИКИ ====================

QVariantList Yadro::getEmployees()
{
    QVariantList list;
    if (!s_db.isOpen()) return list;

    QSqlQuery query(s_db);
    QString sql = R"(
        SELECT e.id, e.name, e.sour_name, a.login, a.password, r.role_name, e.role_id, e.block
        FROM employee e
        LEFT JOIN authorizations a ON e.id = a.employee_id
        LEFT JOIN role r ON e.role_id = r.id
        ORDER BY e.id ASC
    )";

    if (!query.exec(sql)) return list;

    while (query.next()) {
        QVariantMap emp;
        emp["id"] = query.value(0).toString();
        emp["name"] = query.value(1).toString();
        emp["sour_name"] = query.value(2).toString();
        emp["full_name"] = query.value(2).toString() + " " + query.value(1).toString();
        emp["login"] = query.value(3).toString();
        emp["password"] = query.value(4).toString();
        emp["role"] = query.value(5).toString();
        emp["role_id"] = query.value(6).toInt();
        emp["block"] = query.value(7).toBool();
        list.append(emp);
    }
    return list;
}

QVariantList Yadro::getRoles()
{
    QVariantList list;
    if (!s_db.isOpen()) return list;

    QSqlQuery query(s_db);
    if (query.exec("SELECT id, role_name FROM role ORDER BY id ASC")) {
        while (query.next()) {
            QVariantMap role;
            role["id"] = query.value(0).toInt();
            role["name"] = query.value(1).toString();
            list.append(role);
        }
    }
    return list;
}

QString Yadro::updateEmployee(int id, const QString &name, const QString &sourName, const QString &login, const QString &password, int roleId)
{
    if (!s_db.isOpen()) return QStringLiteral("Нет подключения к базе данных.");

    if (!s_db.transaction())
        return QStringLiteral("Не удалось начать транзакцию: %1").arg(s_db.lastError().text());

    QSqlQuery query(s_db);

    query.prepare("UPDATE employee SET name = :name, sour_name = :sour_name, role_id = :role_id WHERE id = :id");
    query.bindValue(":name", name);
    query.bindValue(":sour_name", sourName);
    query.bindValue(":role_id", roleId);
    query.bindValue(":id", id);
    if (!query.exec()) {
        s_db.rollback();
        return QStringLiteral("Ошибка обновления ФИО/Роли: %1").arg(query.lastError().text());
    }

    query.prepare("UPDATE authorizations SET login = :login, password = :password WHERE employee_id = :id");
    query.bindValue(":login", login);
    query.bindValue(":password", password);
    query.bindValue(":id", id);
    if (!query.exec()) {
        s_db.rollback();
        return QStringLiteral("Ошибка обновления логина/пароля: %1").arg(query.lastError().text());
    }

    if (!s_db.commit()) {
        const QString e = s_db.lastError().text();
        s_db.rollback();
        return QStringLiteral("Ошибка фиксации транзакции: %1").arg(e);
    }

    return QString();
}

QString Yadro::createEmployee(const QString &name, const QString &sourName, const QString &login, const QString &password, int roleId)
{
    if (!s_db.isOpen()) return QStringLiteral("Нет подключения к базе данных.");

    QSqlQuery checkQuery(s_db);
    checkQuery.prepare("SELECT id FROM authorizations WHERE login = :login");
    checkQuery.bindValue(":login", login);
    if (checkQuery.exec() && checkQuery.next()) {
        return QStringLiteral("Сотрудник с таким логином уже существует!");
    }

    if (!s_db.transaction())
        return QStringLiteral("Не удалось начать транзакцию: %1").arg(s_db.lastError().text());

    QSqlQuery query(s_db);

    query.prepare("INSERT INTO employee (name, sour_name, role_id, block) VALUES (:name, :sour_name, :role_id, FALSE) RETURNING id");
    query.bindValue(":name", name);
    query.bindValue(":sour_name", sourName);
    query.bindValue(":role_id", roleId);

    if (!query.exec() || !query.next()) {
        s_db.rollback();
        return QStringLiteral("Ошибка создания сотрудника: %1").arg(query.lastError().text());
    }

    int newEmployeeId = query.value(0).toInt();

    query.prepare("INSERT INTO authorizations (employee_id, login, password) VALUES (:emp_id, :login, :password)");
    query.bindValue(":emp_id", newEmployeeId);
    query.bindValue(":login", login);
    query.bindValue(":password", password);

    if (!query.exec()) {
        s_db.rollback();
        return QStringLiteral("Ошибка создания логина: %1").arg(query.lastError().text());
    }

    if (!s_db.commit()) {
        const QString e = s_db.lastError().text();
        s_db.rollback();
        return QStringLiteral("Ошибка фиксации транзакции: %1").arg(e);
    }

    return QString();
}

QString Yadro::deleteEmployee(int id)
{
    if (!s_db.isOpen()) return QStringLiteral("Нет подключения к базе данных.");

    if (!s_db.transaction())
        return QStringLiteral("Не удалось начать транзакцию: %1").arg(s_db.lastError().text());

    QSqlQuery query(s_db);

    query.prepare("DELETE FROM authorizations WHERE employee_id = :id");
    query.bindValue(":id", id);
    if (!query.exec()) {
        s_db.rollback();
        return QStringLiteral("Ошибка удаления авторизации: %1").arg(query.lastError().text());
    }

    query.prepare("DELETE FROM employee WHERE id = :id");
    query.bindValue(":id", id);
    if (!query.exec()) {
        s_db.rollback();
        return QStringLiteral("Ошибка удаления сотрудника: %1").arg(query.lastError().text());
    }

    if (!s_db.commit()) {
        const QString e = s_db.lastError().text();
        s_db.rollback();
        return QStringLiteral("Ошибка фиксации транзакции: %1").arg(e);
    }

    return QString();
}

QString Yadro::setEmployeeBlocked(int id, bool blocked)
{
    if (!s_db.isOpen()) return QStringLiteral("Нет подключения к базе данных.");

    QSqlQuery query(s_db);
    query.prepare("UPDATE employee SET block = :blocked WHERE id = :id");
    query.bindValue(":blocked", blocked);
    query.bindValue(":id", id);

    if (!query.exec())
        return QStringLiteral("Ошибка изменения блокировки: %1").arg(query.lastError().text());

    return QString();
}

// ==================== ОТДЕЛЕНИЯ ====================

QVariantList Yadro::getDepartments()
{
    QVariantList list;
    if (!s_db.isOpen()) return list;

    QSqlQuery query(s_db);
    if (!query.exec("SELECT id, department_name, chamber_capacity, chamber_capacity_disease FROM department ORDER BY id ASC")) {
        qDebug() << "Ошибка получения отделений:" << query.lastError().text();
        return list;
    }

    while (query.next()) {
        QVariantMap dept;
        dept["id"] = query.value(0).toString();
        dept["name"] = query.value(1).toString();
        dept["capacity"] = query.value(2).toString();
        dept["capacity_disease"] = query.value(3).toString();
        list.append(dept);
    }
    return list;
}

QString Yadro::createDepartment(const QString &name, int capacity, int capacityDisease, const QVariantList &chambers)
{
    if (!s_db.isOpen()) return QStringLiteral("Нет подключения к БД.");

    QSqlQuery checkQuery(s_db);
    checkQuery.prepare("SELECT id FROM department WHERE department_name = :name");
    checkQuery.bindValue(":name", name);
    if (checkQuery.exec() && checkQuery.next()) {
        return QStringLiteral("Отделение с таким названием уже существует!");
    }

    if (!s_db.transaction())
        return QStringLiteral("Не удалось начать транзакцию: %1").arg(s_db.lastError().text());

    QSqlQuery query(s_db);

    query.prepare("INSERT INTO department (department_name, chamber_capacity, chamber_capacity_disease) VALUES (:name, :capacity, :disease) RETURNING id");
    query.bindValue(":name", name);
    query.bindValue(":capacity", capacity);
    query.bindValue(":disease", capacityDisease);

    if (!query.exec() || !query.next()) {
        s_db.rollback();
        return QStringLiteral("Ошибка создания: %1").arg(query.lastError().text());
    }

    int newDeptId = query.value(0).toInt();

    for (const QVariant &item : chambers) {
        QVariantMap ch = item.toMap();

        query.prepare("SELECT id FROM chamber WHERE department_id = :dept_id AND number = :number");
        query.bindValue(":dept_id", newDeptId);
        query.bindValue(":number", ch["number"]);
        if (query.exec() && query.next()) {
            s_db.rollback();
            return QStringLiteral("Палата с номером %1 уже существует!").arg(ch["number"].toInt());
        }

        query.prepare("INSERT INTO chamber (number, capacity, department_id, disease, current_load) VALUES (:number, :ch_capacity, :dept_id, :disease, 0)");
        query.bindValue(":number", ch["number"]);
        query.bindValue(":ch_capacity", ch["capacity"]);
        query.bindValue(":dept_id", newDeptId);
        query.bindValue(":disease", ch["disease"]);

        if (!query.exec()) {
            s_db.rollback();
            return QStringLiteral("Ошибка создания палаты: %1").arg(query.lastError().text());
        }
    }

    if (!s_db.commit()) {
        const QString e = s_db.lastError().text();
        s_db.rollback();
        return QStringLiteral("Ошибка фиксации транзакции: %1").arg(e);
    }

    return QString();
}

QString Yadro::updateDepartmentName(int id, const QString &name)
{
    if (!s_db.isOpen()) return QStringLiteral("Нет подключения к базе данных.");

    QSqlQuery query(s_db);
    query.prepare("UPDATE department SET department_name = :name WHERE id = :id");
    query.bindValue(":name", name);
    query.bindValue(":id", id);

    if (!query.exec())
        return QStringLiteral("Ошибка обновления названия: %1").arg(query.lastError().text());

    return QString();
}

QString Yadro::deleteDepartment(int id)
{
    if (!s_db.isOpen()) return QStringLiteral("Нет подключения к базе данных.");

    if (!s_db.transaction())
        return QStringLiteral("Не удалось начать транзакцию: %1").arg(s_db.lastError().text());

    QSqlQuery query(s_db);

    query.prepare("DELETE FROM chamber WHERE department_id = :id");
    query.bindValue(":id", id);
    if (!query.exec()) {
        s_db.rollback();
        return QStringLiteral("Ошибка удаления палат: %1").arg(query.lastError().text());
    }

    query.prepare("DELETE FROM department WHERE id = :id");
    query.bindValue(":id", id);
    if (!query.exec()) {
        s_db.rollback();
        return QStringLiteral("Ошибка удаления отделения: %1").arg(query.lastError().text());
    }

    if (!s_db.commit()) {
        const QString e = s_db.lastError().text();
        s_db.rollback();
        return QStringLiteral("Ошибка фиксации транзакции: %1").arg(e);
    }

    return QString();
}

// ==================== ПАЛАТЫ ====================

QVariantList Yadro::getChambersByDepartment(int departmentId)
{
    QVariantList list;
    if (!s_db.isOpen()) return list;

    QSqlQuery query(s_db);
    query.prepare(R"(
        SELECT number, capacity, disease, (capacity - current_load) AS free_places
        FROM chamber
        WHERE department_id = :dept_id
        ORDER BY number ASC
    )");
    query.bindValue(":dept_id", departmentId);

    if (!query.exec()) {
        qDebug() << "Ошибка получения палат:" << query.lastError().text();
        return list;
    }

    while (query.next()) {
        QVariantMap ch;
        ch["number"] = query.value(0).toInt();
        ch["capacity"] = query.value(1).toInt();
        ch["disease"] = query.value(2).toBool();
        ch["free_places"] = query.value(3).toInt();
        list.append(ch);
    }
    return list;
}

bool Yadro::chamberExists(int departmentId, int number)
{
    if (!s_db.isOpen()) return false;

    QSqlQuery query(s_db);
    query.prepare("SELECT id FROM chamber WHERE department_id = :dept_id AND number = :number");
    query.bindValue(":dept_id", departmentId);
    query.bindValue(":number", number);

    return query.exec() && query.next();
}

QString Yadro::addChamber(int departmentId, int number, int capacity, bool isDisease)
{
    if (!s_db.isOpen()) return QStringLiteral("Нет подключения к БД.");

    if (chamberExists(departmentId, number))
        return QStringLiteral("Палата с таким номером уже существует!");

    QSqlQuery query(s_db);
    query.prepare("INSERT INTO chamber (number, capacity, department_id, disease, current_load) VALUES (:number, :capacity, :dept_id, :disease, 0)");
    query.bindValue(":number", number);
    query.bindValue(":capacity", capacity);
    query.bindValue(":dept_id", departmentId);
    query.bindValue(":disease", isDisease);

    if (!query.exec())
        return QStringLiteral("Ошибка создания палаты: %1").arg(query.lastError().text());

    return QString();
}

QString Yadro::deleteChamberByNumber(int departmentId, int number)
{
    if (!s_db.isOpen()) return QStringLiteral("Нет подключения к БД.");

    QSqlQuery checkLoad(s_db);
    checkLoad.prepare("SELECT current_load FROM chamber WHERE department_id = :dept_id AND number = :number");
    checkLoad.bindValue(":dept_id", departmentId);
    checkLoad.bindValue(":number", number);
    if (checkLoad.exec() && checkLoad.next()) {
        if (checkLoad.value(0).toInt() > 0)
            return QStringLiteral("Нельзя удалить палату: в ней есть пациенты!");
    }

    QSqlQuery query(s_db);
    query.prepare("DELETE FROM chamber WHERE department_id = :dept_id AND number = :number");
    query.bindValue(":dept_id", departmentId);
    query.bindValue(":number", number);

    if (!query.exec())
        return QStringLiteral("Ошибка удаления палаты: %1").arg(query.lastError().text());

    return QString();
}

// ==================== ПАЦИЕНТЫ И ПЕРЕВОДЫ ====================

QVariantList Yadro::getPatients()
{
    QVariantList list;
    if (!s_db.isOpen()) return list;

    QSqlQuery query(s_db);
    QString sql = R"(
        SELECT p.id, p.name, p.sour_name, p.policy, p.pregnancy_period, p.disease,
               d.department_name, c.number AS chamber_number,
               CASE
                   WHEN last_t.chamber_id IS NULL AND EXISTS (SELECT 1 FROM transfer t2 WHERE t2.patient_id = p.id) THEN TRUE
                   ELSE FALSE
               END AS is_discharged
        FROM patient p
        LEFT JOIN LATERAL (
            SELECT t.chamber_id
            FROM transfer t
            WHERE t.patient_id = p.id
            ORDER BY t.date DESC, t.id DESC
            LIMIT 1
        ) last_t ON TRUE
        LEFT JOIN chamber c ON last_t.chamber_id = c.id
        LEFT JOIN department d ON c.department_id = d.id
        ORDER BY
            CASE
                WHEN last_t.chamber_id IS NOT NULL THEN 0
                WHEN last_t.chamber_id IS NULL AND NOT EXISTS (SELECT 1 FROM transfer t2 WHERE t2.patient_id = p.id) THEN 1
                ELSE 2
            END ASC,
            p.id ASC
    )";

    if (!query.exec(sql)) {
        qDebug() << "Ошибка получения пациентов:" << query.lastError().text();
        return list;
    }

    while (query.next()) {
        QVariantMap pat;
        pat["id"] = query.value(0).toInt();
        pat["full_name"] = query.value(2).toString() + " " + query.value(1).toString();
        pat["policy"] = query.value(3).toString();
        pat["pregnancy_period"] = query.value(4).toString();
        pat["disease"] = query.value(5).toBool();
        pat["department"] = query.value(6).isNull() ? "" : query.value(6).toString();
        pat["chamber"] = query.value(7).isNull() ? "" : query.value(7).toString();
        pat["is_discharged"] = query.value(8).toBool();
        list.append(pat);
    }
    return list;
}

QVariantList Yadro::getTransfers()
{
    QVariantList list;
    if (!s_db.isOpen()) return list;

    QSqlQuery query(s_db);
    if (!query.exec("SELECT id, patient_id, employee_id, chamber_id, date FROM transfer ORDER BY id DESC")) {
        qDebug() << "Ошибка получения переводов:" << query.lastError().text();
        return list;
    }

    while (query.next()) {
        QVariantMap tr;
        tr["id"] = query.value(0).toInt();
        tr["patient_id"] = query.value(1).toInt();
        tr["employee_id"] = query.value(2).toInt();
        tr["chamber_id"] = query.value(3).toInt();
        tr["date"] = query.value(4).toString();
        list.append(tr);
    }
    return list;
}

QString Yadro::createPatient(const QString &name, const QString &sourName,
                             const QString &policy, const QString &pregnancyPeriod,
                             bool isDisease)
{
    if (!s_db.isOpen()) return QStringLiteral("Нет подключения к базе данных.");

    QSqlQuery checkQuery(s_db);
    checkQuery.prepare("SELECT id FROM patient WHERE policy = :policy");
    checkQuery.bindValue(":policy", policy);
    if (checkQuery.exec() && checkQuery.next()) {
        return QStringLiteral("Пациентка с таким полисом уже существует!");
    }

    QSqlQuery query(s_db);
    query.prepare(R"(
        INSERT INTO patient (name, sour_name, policy, pregnancy_period, disease)
        VALUES (:name, :sour_name, :policy, :pregnancy_period, :disease)
        RETURNING id
    )");
    query.bindValue(":name", name);
    query.bindValue(":sour_name", sourName);
    query.bindValue(":policy", policy);
    query.bindValue(":pregnancy_period", pregnancyPeriod);
    query.bindValue(":disease", isDisease);

    if (!query.exec() || !query.next()) {
        return QStringLiteral("Ошибка создания пациентки: %1").arg(query.lastError().text());
    }

    return QString();
}

QVariantList Yadro::getPatientsByChamber(int departmentId, int chamberNumber)
{
    QVariantList list;
    if (!s_db.isOpen()) return list;

    QSqlQuery query(s_db);
    query.prepare(R"(
        SELECT p.id, p.name, p.sour_name, p.policy, p.pregnancy_period, p.disease
        FROM patient p
        JOIN LATERAL (
            SELECT t.chamber_id
            FROM transfer t
            WHERE t.patient_id = p.id
            ORDER BY t.date DESC, t.id DESC
            LIMIT 1
        ) last_t ON TRUE
        JOIN chamber c ON last_t.chamber_id = c.id
        WHERE c.department_id = :dept_id AND c.number = :number
        ORDER BY p.id ASC
    )");
    query.bindValue(":dept_id", departmentId);
    query.bindValue(":number", chamberNumber);

    if (!query.exec()) {
        qDebug() << "Ошибка получения пациентов палаты:" << query.lastError().text();
        return list;
    }

    while (query.next()) {
        QVariantMap pat;
        pat["id"] = query.value(0).toInt();
        pat["full_name"] = query.value(2).toString() + " " + query.value(1).toString();
        pat["policy"] = query.value(3).toString();
        pat["pregnancy_period"] = query.value(4).toString();
        pat["disease"] = query.value(5).toBool();
        list.append(pat);
    }
    return list;
}

QString Yadro::transferPatient(int patientId, int departmentId, int chamberNumber)
{
    if (!s_db.isOpen()) return QStringLiteral("Нет подключения к базе данных.");

    if (!s_db.transaction())
        return QStringLiteral("Не удалось начать транзакцию: %1").arg(s_db.lastError().text());

    QSqlQuery query(s_db);

    // 1. Получаем данные пациентки
    query.prepare("SELECT id, disease FROM patient WHERE id = :id FOR UPDATE");
    query.bindValue(":id", patientId);
    if (!query.exec() || !query.next()) {
        s_db.rollback();
        return QStringLiteral("Пациентка не найдена.");
    }
    const bool patientIsDisease = query.value(1).toBool();

    // 2. Ищем ТЕКУЩУЮ палату пациентки (последний перевод), чтобы вычесть из неё 1
    query.prepare("SELECT chamber_id FROM transfer WHERE patient_id = :pid ORDER BY date DESC, id DESC LIMIT 1");
    query.bindValue(":pid", patientId);
    int oldChamberId = -1;
    if (query.exec() && query.next() && !query.value(0).isNull()) {
        oldChamberId = query.value(0).toInt();
    }

    // 3. Проверяем НОВУЮ палату
    query.prepare("SELECT id, capacity, current_load, disease FROM chamber WHERE department_id = :dept_id AND number = :number FOR UPDATE");
    query.bindValue(":dept_id", departmentId);
    query.bindValue(":number", chamberNumber);
    if (!query.exec() || !query.next()) {
        s_db.rollback();
        return QStringLiteral("Палата %1 не найдена в выбранном отделении.").arg(chamberNumber);
    }
    const int newChamberId = query.value(0).toInt();
    const int chamberCapacity = query.value(1).toInt();
    const int currentLoad = query.value(2).toInt();
    const bool chamberIsDisease = query.value(3).toBool();

    // Если пытаемся перевести в ту же самую палату - ничего не делаем
    if (oldChamberId == newChamberId) {
        s_db.rollback();
        return QStringLiteral("Пациентка уже находится в этой палате.");
    }

    // 4. Проверка типа палаты
    if (patientIsDisease != chamberIsDisease) {
        s_db.rollback();
        return patientIsDisease
                   ? QStringLiteral("Пациентка с болезнью — только в изолятор!")
                   : QStringLiteral("Пациентка здорова — нельзя помещать в изолятор.");
    }

    // 5. Проверка свободных мест в НОВОЙ палате
    if (currentLoad >= chamberCapacity) {
        s_db.rollback();
        return QStringLiteral("В палате %1 нет свободных мест.").arg(chamberNumber);
    }

    // 6. Если она лежала в СТАРОЙ палате, уменьшаем там загрузку
    if (oldChamberId != -1) {
        QSqlQuery updOld(s_db);
        updOld.prepare("UPDATE chamber SET current_load = current_load - 1 WHERE id = :ch_id AND current_load > 0");
        updOld.bindValue(":ch_id", oldChamberId);
        if (!updOld.exec()) {
            s_db.rollback();
            return QStringLiteral("Ошибка обновления старой палаты: %1").arg(updOld.lastError().text());
        }
    }

    // 7. Создаем НОВЫЙ перевод
    int currentEmployeeId = 1; // Заглушка. В идеале передавать ID авторизованного врача.
    query.prepare("INSERT INTO transfer (patient_id, employee_id, chamber_id) VALUES (:pid, :emp_id, :ch_id)");
    query.bindValue(":pid", patientId);
    query.bindValue(":emp_id", currentEmployeeId);
    query.bindValue(":ch_id", newChamberId);
    if (!query.exec()) {
        s_db.rollback();
        return QStringLiteral("Ошибка создания перевода: %1").arg(query.lastError().text());
    }

    // 8. Увеличиваем загрузку НОВОЙ палаты
    query.prepare("UPDATE chamber SET current_load = current_load + 1 WHERE id = :ch_id");
    query.bindValue(":ch_id", newChamberId);
    if (!query.exec()) {
        s_db.rollback();
        return QStringLiteral("Ошибка обновления новой палаты: %1").arg(query.lastError().text());
    }

    if (!s_db.commit()) {
        const QString e = s_db.lastError().text();
        s_db.rollback();
        return QStringLiteral("Ошибка фиксации: %1").arg(e);
    }

    return QString();
}

QString Yadro::dischargePatient(int patientId)
{
    if (!s_db.isOpen()) return QStringLiteral("Нет подключения к базе данных.");

    if (!s_db.transaction())
        return QStringLiteral("Не удалось начать транзакцию: %1").arg(s_db.lastError().text());

    QSqlQuery query(s_db);

    query.prepare("SELECT chamber_id FROM transfer WHERE patient_id = :pid ORDER BY date DESC, id DESC LIMIT 1");
    query.bindValue(":pid", patientId);

    int currentChamberId = -1;
    if (query.exec() && query.next() && !query.value(0).isNull()) {
        currentChamberId = query.value(0).toInt();
    }

    if (currentChamberId != -1) {
        QSqlQuery upd(s_db);
        upd.prepare("UPDATE chamber SET current_load = current_load - 1 WHERE id = :ch_id AND current_load > 0");
        upd.bindValue(":ch_id", currentChamberId);
        if (!upd.exec()) {
            s_db.rollback();
            return QStringLiteral("Ошибка обновления загрузки палаты: %1").arg(upd.lastError().text());
        }
    }

    int currentEmployeeId = 1;
    query.prepare("INSERT INTO transfer (patient_id, employee_id, chamber_id) VALUES (:pid, :emp_id, NULL)");
    query.bindValue(":pid", patientId);
    query.bindValue(":emp_id", currentEmployeeId);

    if (!query.exec()) {
        s_db.rollback();
        return QStringLiteral("Ошибка создания записи о выписке: %1").arg(query.lastError().text());
    }

    if (!s_db.commit()) {
        const QString e = s_db.lastError().text();
        s_db.rollback();
        return QStringLiteral("Ошибка фиксации: %1").arg(e);
    }

    return QString();
}