#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QDebug>
#include "yadro.h"

int main(int argc, char *argv[])
{
    QQuickStyle::setStyle("Fusion");
    QGuiApplication app(argc, argv);

    Yadro yadro;

    // Подключаемся к базе данных
    QString err = yadro.connectToDatabase(
        "192.168.1.150",
        5432,
        "Perinatal",
        "postgres",
        "Ao6rhpiop"
    );

    if (!err.isEmpty()) {
        qCritical() << "Критическая ошибка БД:" << err;
    }

    QQmlApplicationEngine engine;
    engine.loadFromModule("PerinatalCenter", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}