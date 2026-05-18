#include "timermanager.h"

TimerManager::TimerManager(ScheduleModel *model, QObject *parent)
    : QObject{parent}, schedule(model)
{
    timer = new QTimer(this);
    connect(timer, &QTimer::timeout, this, &TimerManager::processSchedules);

    timer->start(1000);
}

int TimerManager::currentMode()
{
    return mCurrentMode;
}

int TimerManager::secondsRemaining()
{
    return mSecondsRemaining;
}

int TimerManager::totalDuration()
{
    return mTotalDuration;
}

QString TimerManager::nextScheduleName()
{
    return mNextScheduleName;
}

void TimerManager::processSchedules()
{
    if (!schedule) {
        return;
    }

    QDateTime now = QDateTime::currentDateTime();
    bool scheduleRunning = false;

    // Fallback trackers for finding the next chronological event
    qint64 minimumTimeDifference = std::numeric_limits<qint64>::max();
    int shortestRunningDuration = std::numeric_limits<int>::max();
    QString upcomingName = "";

    // Access data safely from your existing mSchedules QList
    const QList<ScheduleItem> &schedules = schedule->getSchedulesList();

    for (const auto &item : schedules) {
        if (!item.isEnabled) {
            continue;
        }

        QDateTime endTime = item.startTime.addSecs(item.timer);

        // Scenario A: Item is currently running right now
        if (now >= item.startTime && now < endTime) {
            int currentTotalSeconds = item.timer;

            if (!scheduleRunning || currentTotalSeconds < shortestRunningDuration) {
                mSecondsRemaining = static_cast<int>(now.secsTo(endTime));
                mTotalDuration = currentTotalSeconds;
                mCurrentMode = mapModeToIndex(item.mode);

                shortestRunningDuration = currentTotalSeconds;
                scheduleRunning = true;
            }
        }
        // Scenario B: Item is in the future. Find the closest upcoming one
        else if (item.startTime > now) {
            qint64 diff = now.secsTo(item.startTime);

            if (diff < minimumTimeDifference) {
                minimumTimeDifference = diff;
                upcomingName = item.name;
            }
        }
    }

    // Reset properties to zero idle state if no active windows are open
    if (!scheduleRunning) {
        mSecondsRemaining = 0;
        mTotalDuration = 1;
    }

    mNextScheduleName = upcomingName;
    emit timerUpdated();
}

int TimerManager::mapModeToIndex(const QString &modeStr)
{
    QString upper = modeStr.toUpper();

    if (upper == "COOL") return 1;
    if (upper == "DRY") return 2;
    return 0;
}
