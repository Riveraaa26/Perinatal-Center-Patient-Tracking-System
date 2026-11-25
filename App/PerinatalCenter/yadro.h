#pragma once
#include <QDateTime>
#include <QObject>
#include <QString>
#include <QSqlDatabase>
#include <QVariantList>
#include <QVariantMap>
#include <qqmlintegration.h>

class Yadro : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit Yadro(QObject *parent = nullptr);

    Q_INVOKABLE QString connectToDatabase(const QString &host, int port, const QString &dbName, const QString &user, const QString &password);
    Q_INVOKABLE QString loginUser(const QString &login, const QString &password);

    // Сотрудники
    Q_INVOKABLE QVariantList getEmployees();
    Q_INVOKABLE QVariantList getRoles();
    Q_INVOKABLE QString updateEmployee(int id, const QString &name, const QString &sourName, const QString &login, const QString &password, int roleId);
    Q_INVOKABLE QString createEmployee(const QString &name, const QString &sourName, const QString &login, const QString &password, int roleId);
    Q_INVOKABLE QString deleteEmployee(int id);
    Q_INVOKABLE QString setEmployeeBlocked(int id, bool blocked);

    // Отделения
    Q_INVOKABLE QVariantList getDepartments();
    Q_INVOKABLE QString createDepartment(const QString &name, int capacity, int capacityDisease, const QVariantList &chambers);
    Q_INVOKABLE QString updateDepartmentName(int id, const QString &name);
    Q_INVOKABLE QString deleteDepartment(int id);

    // Палаты
    Q_INVOKABLE QVariantList getChambersByDepartment(int departmentId);
    Q_INVOKABLE bool chamberExists(int departmentId, int number);
    Q_INVOKABLE QString addChamber(int departmentId, int number, int capacity, bool isDisease);
    Q_INVOKABLE QString deleteChamberByNumber(int departmentId, int number);

    // Пациенты и Переводы
    Q_INVOKABLE QVariantList getPatients();
    Q_INVOKABLE QVariantList getTransfers();

    // Создать пациента
    Q_INVOKABLE QString createPatient(const QString &name, const QString &sourName,
                                      const QString &policy, const QString &pregnancyPeriod,
                                      bool isDisease);

    // Пациенты конкретной палаты
    Q_INVOKABLE QVariantList getPatientsByChamber(int departmentId, int chamberNumber);

    // === Перевод и выписка (передаем ID сотрудника из QML) ===
    Q_INVOKABLE QString transferPatient(int patientId, int departmentId, int chamberNumber, int employeeId);
    Q_INVOKABLE QString dischargePatient(int patientId, int employeeId);

    Q_INVOKABLE QVariantList getTransferHistory();

private:
    static QSqlDatabase s_db;
};