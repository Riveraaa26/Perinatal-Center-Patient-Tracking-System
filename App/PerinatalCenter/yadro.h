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
    Q_PROPERTY(QString readError READ readError NOTIFY readErrorChanged)

public:
    QString readError() const { return m_readError; }
    explicit Yadro(QObject *parent = nullptr);

    Q_INVOKABLE QString connectToDatabase(const QString &host, int port, const QString &dbName,
                                          const QString &user, const QString &password);
    Q_INVOKABLE QString databaseStatus() const;
    Q_INVOKABLE QString loginUser(const QString &login, const QString &password);
    Q_INVOKABLE void logoutUser();
    Q_INVOKABLE QString generatePassword() const;

    Q_INVOKABLE QVariantList getEmployees();
    Q_INVOKABLE QVariantList getRoles();
    Q_INVOKABLE QString updateEmployee(int id, const QString &name, const QString &sourName,
                                       const QString &login, const QString &password, int roleId);
    Q_INVOKABLE QString createEmployee(const QString &name, const QString &sourName,
                                       const QString &login, const QString &password, int roleId);
    Q_INVOKABLE QString deleteEmployee(int id); // безопасная деактивация вместо физического удаления
    Q_INVOKABLE QString setEmployeeBlocked(int id, bool blocked);

    Q_INVOKABLE QVariantList getDepartments();
    Q_INVOKABLE QString createDepartment(const QString &name, int capacity,
                                         int capacityDisease, const QVariantList &chambers);
    Q_INVOKABLE QString updateDepartmentName(int id, const QString &name);
    Q_INVOKABLE QString deleteDepartment(int id);
    Q_INVOKABLE QVariantList getChambersByDepartment(int departmentId);
    Q_INVOKABLE bool chamberExists(int departmentId, int number);
    Q_INVOKABLE QString addChamber(int departmentId, int number, int capacity, bool isDisease);
    Q_INVOKABLE QString deleteChamberByNumber(int departmentId, int number);

    Q_INVOKABLE QVariantList getPatients();
    Q_INVOKABLE QVariantList getTransfers();
    Q_INVOKABLE QVariantList getPatientHistory(int patientId);
    Q_INVOKABLE QVariantList getOccupancyStatistics();
    Q_INVOKABLE QString createPatient(const QString &name, const QString &sourName,
                                      const QString &policy, const QString &pregnancyPeriod,
                                      bool isDisease);
    Q_INVOKABLE QVariantList getPatientsByChamber(int departmentId, int chamberNumber);
    Q_INVOKABLE QString transferPatient(int patientId, int departmentId, int chamberNumber, int expectedVersion = -1);
    Q_INVOKABLE QString dischargePatient(int patientId, const QString &recommendations, const QString &date, int expectedVersion = -1);

signals:
    void readErrorChanged();
private:
    QString m_readError;
    void setReadError(const QString &message);
    static QSqlDatabase s_db;
    int m_employeeId = -1;
    QString m_role;
    static QString s_connectionError;

    bool beginWrite();
    bool ready() const;
    bool active() const;
    bool admin() const;
    bool clinician() const;
    bool head() const;
    bool canRegister() const;
    QString roleError() const;
    bool audit(const QString &action, const QString &target, int targetId);
    bool updateLoad(int chamberId, int expectedLoad);
    int actualLoad(int chamberId, bool *ok = nullptr);
};
