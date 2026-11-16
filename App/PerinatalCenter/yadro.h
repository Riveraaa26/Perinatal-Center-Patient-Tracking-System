#pragma once

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
    // Возвращает ФИО при успехе, или текст ошибки при неудаче
    Q_INVOKABLE QString loginUser(const QString &login, const QString &password);

    Q_INVOKABLE QVariantList getChambersByDepartment(int departmentId);
    // Сотрудники
    Q_INVOKABLE QVariantList getEmployees();
    Q_INVOKABLE QVariantList getRoles();
    Q_INVOKABLE QString updateEmployee(int id, const QString &name, const QString &sourName, const QString &login, const QString &password, int roleId);
    Q_INVOKABLE QString createEmployee(const QString &name, const QString &sourName, const QString &login, const QString &password, int roleId);
    Q_INVOKABLE QString deleteEmployee(int id);

    // Отделения
    Q_INVOKABLE QVariantList getDepartments();
    Q_INVOKABLE QString createDepartment(const QString &name, int capacity, int capacityDisease, const QVariantList &chambers);
    Q_INVOKABLE QString updateDepartmentName(int id, const QString &name);
    Q_INVOKABLE QString deleteDepartment(int id);

    // Палаты
    Q_INVOKABLE int getNextChamberNumber(int departmentId);
    Q_INVOKABLE QString addChamber(int departmentId, int number, int capacity, bool isDisease);
    Q_INVOKABLE QVariantMap getLastChamber(int departmentId);
    Q_INVOKABLE QVariantMap getLastChamberByType(int departmentId, bool isDisease);
    Q_INVOKABLE QString deleteChamber(int chamberId);

    // Пациенты и Переводы
    Q_INVOKABLE QVariantList getPatients();
    Q_INVOKABLE QVariantList getTransfers();

private:
    static QSqlDatabase s_db;
};