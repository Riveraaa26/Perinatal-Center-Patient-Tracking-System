#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QDebug>
#include <QByteArray>
#include "yadro.h"

int main(int argc, char *argv[])
{
    QQuickStyle::setStyle("Fusion");
    QGuiApplication app(argc, argv);

    // Настройки задаются в Qt Creator: Проекты → Запуск → Окружение.
    // Пароли и адрес разработчика НЕ хранятся в исходниках/репозитории.
    const QString host = qEnvironmentVariable("PERINATAL_DB_HOST", "127.0.0.1");
    bool validPort = false;
    const int parsedPort = qEnvironmentVariable("PERINATAL_DB_PORT", "5432").toInt(&validPort);
    const int port = validPort && parsedPort > 0 && parsedPort <= 65535 ? parsedPort : 0;
    const QString dbName = qEnvironmentVariable("PERINATAL_DB_NAME", "Perinatal");
    const QString user = qEnvironmentVariable("PERINATAL_DB_USER", "perinatal_app");
    const QString password = qEnvironmentVariable("PERINATAL_DB_PASSWORD");
    const QString sslMode = qEnvironmentVariable("PERINATAL_DB_SSLMODE", "prefer");
    // Для удалённой БД в защищённой сети задайте PERINATAL_DB_SSLMODE=verify-full
    // и настройте сертификат сервера PostgreSQL согласно документации libpq.
    qputenv("PGSSLMODE", sslMode.toUtf8());

    // SQL-соединение живёт весь срок работы приложения; QML использует тот же именованный коннект.
    Yadro db;
    const QString error = db.connectToDatabase(host, port, dbName, user, password);
    if (!error.isEmpty()) qWarning().noquote() << error;

    QQmlApplicationEngine engine;
    engine.loadFromModule("PerinatalCenter", "Main");
    return engine.rootObjects().isEmpty() ? -1 : app.exec();
}
