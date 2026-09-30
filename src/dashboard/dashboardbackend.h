#ifndef DASHBOARDBACKEND_H
#define DASHBOARDBACKEND_H

#include <QObject>

#include "utils/databasemanager.h"

// Reads/writes the shared device_state table (IDU-1 / ODU-1 rows) that
// sys_control also watches, so the dashboard reflects live device data.
class DashboardBackend : public QObject
{
    Q_OBJECT

    Q_PROPERTY(double indoorTemp READ indoorTemp NOTIFY changed)
    Q_PROPERTY(double outdoorTemp READ outdoorTemp NOTIFY changed)
    Q_PROPERTY(double humidity READ humidity NOTIFY changed)
    Q_PROPERTY(double targetTemp READ targetTemp NOTIFY changed)
    Q_PROPERTY(QString mode READ mode NOTIFY changed)
    Q_PROPERTY(QString fanSpeed READ fanSpeed NOTIFY changed)
    Q_PROPERTY(bool isOn READ isOn NOTIFY changed)
    Q_PROPERTY(bool hasData READ hasData NOTIFY changed)

public:
    explicit DashboardBackend(DatabaseManager *db, QObject *parent = nullptr);

    double indoorTemp() const { return mIndoorTemp; }
    double outdoorTemp() const { return mOutdoorTemp; }
    double humidity() const { return mHumidity; }
    double targetTemp() const { return mTargetTemp; }
    QString mode() const { return mMode; }
    QString fanSpeed() const { return mFanSpeed; }
    bool isOn() const { return mIsOn; }
    bool hasData() const { return mHasData; }

    Q_INVOKABLE void setTargetTemp(double celsius);
    Q_INVOKABLE void setMode(const QString &mode);
    Q_INVOKABLE void setFanSpeed(const QString &fanSpeed);
    Q_INVOKABLE void togglePower();

public slots:
    void reload();

signals:
    void changed();

private:
    void writeField(const QString &column, const QVariant &value);
    void ensureIduRow();

    DatabaseManager *mDb;

    double mIndoorTemp = 0.0;
    double mOutdoorTemp = 0.0;
    double mHumidity = 0.0;
    double mTargetTemp = 25.0;
    QString mMode = QStringLiteral("auto");
    QString mFanSpeed = QStringLiteral("auto");
    bool mIsOn = false;
    bool mHasData = false;
};

#endif // DASHBOARDBACKEND_H
