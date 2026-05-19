#include "schedulemodel.h"

ScheduleModel::ScheduleModel(DatabaseManager *db, QObject *parent)
    : QAbstractListModel{parent}, dbManager(db)
{
    QString schema = "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                     "name TEXT NOT NULL, "
                     "mode TEXT, "
                     "startTime TEXT, "
                     "timer INTEGER, "
                     "isEnabled INTEGER CHECK (isEnabled IN (0, 1)), "
                     "repeatType INTEGER, "
                     "repeatDays TEXT";

    bool success = dbManager->createTable("schedules", schema);

    if (success) {
        qDebug() << "Schedules table created successfully!";
    } else {
        qDebug() << "Failed to create schedules table.";
    }

    loadAllItems();
}

int ScheduleModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return mSchedules.count();
}

QVariant ScheduleModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= mSchedules.count()) {
        return QVariant();
    }

    const ScheduleItem &schedule = mSchedules[index.row()];

    switch (role) {
    case IdRole:
        return schedule.id;
    case NameRole:
        return schedule.name;
    case ModeRole:
        return schedule.mode;
    case StartTimeRole:
        return schedule.startTime;
    case TimerRole:
        return schedule.timer;
    case IsEnabledRole:
        return schedule.isEnabled;
    case RepeatTypeRole:
        return schedule.repeatType;
    case RepeatDaysRole:
        return schedule.repeatDays;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> ScheduleModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[IdRole] = "id";
    roles[NameRole] = "name";
    roles[ModeRole] = "mode";
    roles[StartTimeRole] = "startTime";
    roles[TimerRole] = "timer";
    roles[IsEnabledRole] = "isEnabled";
    roles[RepeatTypeRole] = "repeatType";
    roles[RepeatDaysRole] = "repeatDays";
    return roles;
}

void ScheduleModel::loadAllItems()
{
    // Fetch all records
    QVariantList records = dbManager->fetchAll("schedules");

    for (const QVariant &record : qAsConst(records)) {
        QVariantMap row = record.toMap();

        ScheduleItem item;
        item.id = row["id"].toInt();
        item.name = row["name"].toString();
        item.mode = row["mode"].toString();
        item.timer = row["timer"].toInt();
        item.repeatType = row["repeatType"].toInt();
        item.repeatDays = row["repeatDays"].toString();

        // Convert SQLite text back into a proper QDateTime object
        item.startTime = QDateTime::fromString(row["startTime"].toString(), Qt::ISODate);

        // Convert SQLite 1/0 integer back into a C++ bool
        item.isEnabled = row["isEnabled"].toBool();

        // 5. Append to your model's internal memory array
        mSchedules.append(item);
    }
}

void ScheduleModel::addItem(const QString &name, const QString &mode, const QDateTime &startTime, const int &timer, const int &repeatType, const QString &repeatDays)
{
    QVariantMap data;
    data["name"] = name;
    data["mode"] = mode;
    data["startTime"] = startTime.toString(Qt::ISODate);
    data["timer"] = timer;
    data["isEnabled"] = true;
    data["repeatType"] = repeatType;
    data["repeatDays"] = repeatDays;

    int itemId = dbManager->insertRecord("schedules", data);

    if (itemId == -1) {
        qDebug() << "Failed to insert record.";
        return;
    }

    qDebug() << "Record inserted successfully.";

    beginInsertRows(QModelIndex(), mSchedules.size(), mSchedules.size());
    mSchedules.append({itemId, name, mode, startTime, timer, true, repeatType, repeatDays});
    endInsertRows();
}

void ScheduleModel::editItem(int index, const QString &name, const QString &mode, const QDateTime &startTime, const int &timer, const int &repeatType, const QString &repeatDays)
{
    if (index < 0 || index >= mSchedules.count()) {
        return;
    }

    const ScheduleItem &schedule = mSchedules[index];

    QVariantMap data;
    data["name"] = name;
    data["mode"] = mode;
    data["startTime"] = startTime.toString(Qt::ISODate);
    data["timer"] = timer;
    data["repeatType"] = repeatType;
    data["repeatDays"] = repeatDays;

    QString whereClause = QString("id = %1").arg(schedule.id);
    bool success = dbManager->updateRecord("schedules", data, whereClause);

    if (!success) {
        qDebug() << "Failed to update the record.";
        return;
    }

    qDebug() << "Record updated successfully";

    mSchedules[index] = {schedule.id, name, mode, startTime, timer, schedule.isEnabled, repeatType, repeatDays};
    QModelIndex modelIndex = createIndex(index, 0);

    emit dataChanged(modelIndex, modelIndex, {
        IdRole, NameRole, ModeRole, StartTimeRole, TimerRole, IsEnabledRole, RepeatTypeRole, RepeatDaysRole
    });
}

void ScheduleModel::removeItem(int index)
{
    if (index < 0 || index >= mSchedules.size()) {
        return;
    }

    const ScheduleItem &schedule = mSchedules[index];

    QString whereClause = QString("id = %1").arg(schedule.id);
    bool deleteSuccess = dbManager->deleteRecord("schedules", whereClause);

    if (deleteSuccess) {
        qDebug() << "Record deleted successfully.";
    } else {
        qDebug() << "Failed to delete record.";
    }

    beginRemoveRows(QModelIndex(), index, index);
    mSchedules.removeAt(index);
    endRemoveRows();
}

void ScheduleModel::setItemEnabled(int index, bool enable)
{
    if (index < 0 || index >= mSchedules.size() || mSchedules[index].isEnabled == enable) {
        return;
    }

    const ScheduleItem &schedule = mSchedules[index];

    QVariantMap data;
    data["isEnabled"] = enable;

    QString whereClause = QString("id = %1").arg(schedule.id);
    bool success = dbManager->updateRecord("schedules", data, whereClause);

    if (!success) {
        qDebug() << "Failed to update the record.";
        return;
    }

    qDebug() << "Record updated successfully";

    mSchedules[index].isEnabled = enable;
    QModelIndex modelIndex = createIndex(index, 0);

    qDebug() << "Index: " << index << " Status: " << enable;

    emit dataChanged(modelIndex, modelIndex, {IsEnabledRole});
}

const QList<ScheduleItem> &ScheduleModel::getSchedulesList()
{
    return mSchedules;
}

