# AGENTS.md — scheduler

Qt 5.15 QML desktop app ("Timer & Scheduler") for timed schedules across
Heat/Cool/Dry modes. QML frontend + C++ backends exposed as **context
properties** (no qmlRegisterType). Read this before touching `src/` or `qmls/`.

## Commands

| Task | Command |
|------|---------|
| Configure | `qmake scheduler.pro` (Qt 5.15.2 MinGW 64-bit, `D:/QT/5.15.2/mingw81_64`) |
| Build | `mingw32-make` in `build/` |
| Translations | Automatic — `scheduler.pro` runs `lrelease` at qmake time; `.qm` embedded via `translations/i18n.qrc` |

No test framework exists. Verify by running the app.

## Architecture

```
main.cpp            wires every backend as a context property + QFileSystemWatcher (300ms debounce) → SettingsRepository::reload
src/<feature>/      C++ backends, one folder per feature
  schedule/         ScheduleModel (QAbstractListModel over ScheduleItem) + Q_INVOKABLE CRUD. schedule.h/cpp is a stub — ignore.
  timer/            TimerManager: 1s tick, currentMode/secondsRemaining/nextSchedule properties, previewNextOccurrence()
  dashboard/        DashboardBackend: reads/writes shared device_state table (rows IDU-1/ODU-1)
  settings/         SettingsRepository (DB-backed) → AppSettings facade → SettingsCategoryModel/SettingsItemModel
utils/              DBManager (generic SQLite CRUD + 2s external-change poll → externalDatabaseChanged signal),
                    DbPathResolver (shared DB path — see Inter-project contract), StringHelper
config/             StyleConfig.qml singleton — ALL colors/icons/mode-colors go here, never hardcode in views
qmls/               main.qml (StackView + sidebar), menu/, timer/, schedule/, dashboard/, settings/, dialogs/, toast/, common/
resources/          seed.sql, schema_check.sql, fonts, icons
translations/       5 .ts files (en/hi/kn/ta/ko) + generated .qm + i18n.qrc
```

- Data flow: QML ↔ context properties ↔ DBManager ↔ SQLite. Schedules change →
  `schedulesChanged` → TimerManager re-evaluates next occurrence.
- External DB writes (by sys_control) surface via two paths: DBManager's 2s
  `PRAGMA data_version` poll **and** the QFileSystemWatcher in main.cpp. Don't
  remove either; the sibling app depends on this latency being ~2s.

## Conventions

- C++ files: lowercase-no-separator in `src/<feature>/` (`schedulemodel.h`),
  **except** `src/settings/` which uses PascalCase (`AppSettings.h`) — follow the
  folder you're in, don't "fix" the inconsistency.
- QML files: PascalCase per component. Classes PascalCase; members `m`-prefixed
  (`mIndoorTemp`); `k`-prefixed constants in anonymous namespaces (`kIduUnitId`).
- Classic `#ifndef X_H` guards. QML exposure via `Q_OBJECT` + `Q_PROPERTY` +
  `Q_INVOKABLE`, registered as context properties in main.cpp.
- Includes use project-relative paths: `"utils/databasemanager.h"`.
- Comments: sparse, "why" only. Log lines carry a tag prefix (`[DbPathResolver]`).
- New user-visible strings must go through `qsTr` + the `.ts` files.

## Inter-project contract with sys_control (Flutter)

The two apps are separate processes coupled **only** through one shared SQLite
DB. Changing any of the following unilaterally breaks the sibling app
(`D:\TechNova\sys_control`) — coordinate schema/behavior changes in both repos
in the same change set.

1. **DB path resolution** (`utils/dbpathresolver.*`, mirrored by
   `core/database/db_path_resolver.dart`): `<GenericConfigLocation>/LG/deluxe.json`
   key `db_path` (Windows: `%LOCALAPPDATA%\LG\`) → else `LG/deluxe.db`; legacy CWD `scheduler.db` is
   migrated. Both apps must resolve identically.
2. **journal_mode = DELETE, busy_timeout = 3000.** Never switch to WAL — it
   causes SQLITE_BUSY contention between the two processes.
3. **`device_state` table** (unitId PK, unitType, temperature, humidity,
   targetTemp, mode, fanSpeed, isOn, updatedAt): written by sys_control's
   sensor sim, read/written back by DashboardBackend. Column names are
   camelCase — keep them; drift tables on the Flutter side mirror this schema.
4. **`schedules` table**: Qt-side camelCase schema is the source of truth;
   sys_control's drift migrations adopt (never recreate) it. Any column change
   here must land in sys_control's `app_database.dart` migrations too.
5. **External-change detection**: sys_control polls `PRAGMA data_version` every
   2s + watches the DB dir (300ms debounce), mirroring DBManager. Keep write
   patterns transactional; don't replace the DB file while the app runs
   (sys_control recreates its whole DB provider on file replacement — treat
   that as the fallback path, not the normal one).
