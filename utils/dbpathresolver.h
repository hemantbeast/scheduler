#ifndef DBPATHRESOLVER_H
#define DBPATHRESOLVER_H

#include <QString>

// Resolves the shared database location used by both the scheduler (Qt)
// and sys_control (Flutter) apps.
//
// Order:
//   1. "db_path" from <config>/LG/deluxe.json, if the file exists there
//      (created automatically when missing)
//   2. Default: <config>/LG/deluxe.db — on Windows %LOCALAPPDATA%/LG/deluxe.db
//      (legacy ./scheduler.db is copied over on first run when the default
//      location is still empty)
class DbPathResolver
{
public:
    static QString configFilePath();
    static QString defaultDatabasePath();
    static QString configuredDatabasePath();
    static QString resolve();

private:
    static QString lgDir();
    static void migrateLegacyFile();
};

#endif // DBPATHRESOLVER_H
