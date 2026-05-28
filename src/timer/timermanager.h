#ifndef TIMERMANAGER_H
#define TIMERMANAGER_H

#include <QObject>
#include <QString>
#include <QTimer>
#include <QDateTime>

#include "src/schedule/schedulemodel.h"

class TimerManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int currentMode READ currentMode WRITE setCurrentMode NOTIFY timerUpdated)
    Q_PROPERTY(int secondsRemaining READ secondsRemaining NOTIFY timerUpdated)
    Q_PROPERTY(int totalDuration READ totalDuration NOTIFY timerUpdated)
    Q_PROPERTY(QString nextScheduleName READ nextScheduleName NOTIFY timerUpdated)
    Q_PROPERTY(int activeScheduleId READ activeScheduleId NOTIFY timerUpdated)
    Q_PROPERTY(QString activeScheduleName READ activeScheduleName NOTIFY timerUpdated)

public:
    explicit TimerManager(ScheduleModel *model, QObject *parent = nullptr);

    int currentMode();

    void setCurrentMode(const int &index);

    int secondsRemaining();

    int totalDuration();

    QString nextScheduleName();

    int activeScheduleId();

    QString activeScheduleName();

    Q_INVOKABLE void stopTimer();

    Q_INVOKABLE QString previewNextOccurrence(const QString &mode, const QDateTime &startTime,
                                               int timer, int repeatType, const QString &repeatDays);

signals:
    void timerUpdated();
    void timerCompleted();

public slots:
    void processSchedules();

private:
    ScheduleModel *schedule;
    QTimer *timer;

    int mCurrentMode = 0;
    int mUserMode = -1;

    int mSecondsRemaining = 0;
    int mTotalDuration = 1;
    QString mNextScheduleName = "";
    int mActiveScheduleId = -1;
    QString mActiveScheduleName = "";
    bool mWasRunning = false;

    int mapModeToIndex(const QString &modeStr);
    QDateTime calculateNextOccurance(const ScheduleItem &item, const QDateTime &now);
};

#endif // TIMERMANAGER_H
