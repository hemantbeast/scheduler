#ifndef SCHEDULEMODEL_H
#define SCHEDULEMODEL_H

#include <QAbstractListModel>
#include <QDebug>
#include <QObject>
#include <QString>
#include <QDateTime>
#include <QList>
#include <QVariant>

#include "utils/databasemanager.h"

struct ScheduleItem {
    int id;
    QString name;
    QString mode;
    QDateTime startTime;
    int timer;
    bool isEnabled;
    int repeatType;
    QString repeatDays;
};


class ScheduleModel : public QAbstractListModel
{
    Q_OBJECT

    enum ScheduleRole {
        IdRole,
        NameRole = Qt::UserRole + 1,
        ModeRole,
        StartTimeRole,
        TimerRole,
        IsEnabledRole,
        RepeatTypeRole,
        RepeatDaysRole
    };

public:
    explicit ScheduleModel(DatabaseManager *db, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent) const;

    QVariant data(const QModelIndex &index, int role) const;

    QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE void loadAllItems();

    Q_INVOKABLE void addItem(const QString &name, const QString &mode, const QDateTime &startTime, const int &timer, const int &repeatType, const QString &repeatDays);

    Q_INVOKABLE void editItem(int index, const QString &name, const QString &mode, const QDateTime &startTime, const int &timer, const int &repeatType, const QString &repeatDays);

    Q_INVOKABLE void removeItem(int index);

    Q_INVOKABLE void setItemEnabled(int index, bool enable);

    Q_INVOKABLE bool nameExists(const QString &name);

    const QList<ScheduleItem>& getSchedulesList();

private:
    DatabaseManager *dbManager;
    QList<ScheduleItem> mSchedules;
};

#endif // SCHEDULEMODEL_H
