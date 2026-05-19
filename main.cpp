#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>

#include "src/schedule/schedulemodel.h"
#include "src/timer/timermanager.h"
#include "utils/stringhelper.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // Tell the engine to look inside your source directory for modules
    engine.addImportPath(":/");

    // Register database manager
    DatabaseManager *dbGlobal = new DatabaseManager("scheduler.db", &app);
    engine.rootContext()->setContextProperty("DBManager", dbGlobal);

    // Initialize Schedule model and Timer manager
    ScheduleModel *scheduleModel = new ScheduleModel(dbGlobal, &app);
    TimerManager *timerManager = new TimerManager(scheduleModel, &app);

    // Register schedule model and timer manager
    engine.rootContext()->setContextProperty("scheduleModel", scheduleModel);
    engine.rootContext()->setContextProperty("timerManager", timerManager);

    StringHelper strHelper;
    engine.rootContext()-> setContextProperty("StringHelper", &strHelper);

    const QUrl url(QStringLiteral("qrc:/qmls/main.qml"));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.load(url);

    return QCoreApplication::exec();
}
