#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QFileSystemWatcher>
#include <QTimer>
#include <QFileInfo>

#include "src/schedule/schedulemodel.h"
#include "src/timer/timermanager.h"
#include "utils/stringhelper.h"
#include "src/settings/AppSettings.h"
#include "src/settings/SettingsRepository.h"
#include "src/settings/SettingsCategoryModel.h"
#include "src/settings/SettingsItemModel.h"

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
    dbGlobal->enableExternalChangeDetection(2000);
    engine.rootContext()->setContextProperty("DBManager", dbGlobal);

    // Initialize Schedule model and Timer manager
    ScheduleModel *scheduleModel = new ScheduleModel(dbGlobal, &app);
    TimerManager *timerManager = new TimerManager(scheduleModel, &app);

    // Register schedule model and timer manager
    engine.rootContext()->setContextProperty("scheduleModel", scheduleModel);
    engine.rootContext()->setContextProperty("timerManager", timerManager);

    QObject::connect(scheduleModel, &ScheduleModel::schedulesChanged,
                     timerManager, &TimerManager::processSchedules);

    QObject::connect(dbGlobal, &DatabaseManager::externalDatabaseChanged,
                     scheduleModel, &ScheduleModel::loadAllItems);

    StringHelper strHelper;
    engine.rootContext()-> setContextProperty("StringHelper", &strHelper);

    // Initialize settings repository
    SettingsRepository *settingsRepo = new SettingsRepository(dbGlobal->getDb(), &app);

    if (!settingsRepo->open()) {
        qFatal("Could not open settings database");
        return 1;
    }

    settingsRepo->observeDatabaseChanges(dbGlobal);

    // Initialize settings facade; applies the saved language before QML loads
    AppSettings *appSettings = new AppSettings(settingsRepo, &engine, &app);

    SettingsCategoryModel *settingsCategory = new SettingsCategoryModel(settingsRepo, &app);
    SettingsItemModel *settingsItem = new SettingsItemModel(settingsRepo, &app);

    // Re-resolve DB-driven labels after a language change
    QObject::connect(appSettings, &AppSettings::languageChanged,
                     settingsCategory, &SettingsCategoryModel::reload);
    QObject::connect(appSettings, &AppSettings::languageChanged,
                     settingsItem, &SettingsItemModel::reload);

    engine.rootContext()->setContextProperty("categoryModel", settingsCategory);
    engine.rootContext()->setContextProperty("itemModel", settingsItem);
    engine.rootContext()->setContextProperty("settingsRepo", settingsRepo);
    engine.rootContext()->setContextProperty("appSettings", appSettings);

    /// Watcher for any database changes from external source.
    QFileSystemWatcher *dbWatcher = new QFileSystemWatcher(&app);
    QTimer *reloadDebounce = new QTimer(&app);

    reloadDebounce->setSingleShot(true);
    reloadDebounce->setInterval(300);

    const QString dbPath = QFileInfo(dbGlobal->getDb().databaseName()).absoluteFilePath();
    const QString dbDir = QFileInfo(dbPath).absolutePath();

    dbWatcher->addPath(dbDir);

    // Track the last known modification time
    static QDateTime lastModTime = QFileInfo(dbPath).lastModified();

    QObject::connect(dbWatcher, &QFileSystemWatcher::directoryChanged, reloadDebounce, [dbPath, reloadDebounce]() {
        QFileInfo checkFile(dbPath);

        // Ensure file exists and its modification time actually changed
        if (checkFile.exists() && checkFile.lastModified() > lastModTime) {
            lastModTime = checkFile.lastModified();
            qDebug() << "DB file change detected via directory monitoring.";
            reloadDebounce->start();
        }
    });

    QObject::connect(reloadDebounce, &QTimer::timeout, settingsRepo, &SettingsRepository::reload);

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
