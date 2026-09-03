#ifndef APPSETTINGS_H
#define APPSETTINGS_H

#include <QObject>
#include <QTranslator>
#include <QVariant>
#include <QQmlEngine>

#include "SettingsRepository.h"

// Reactive facade over SettingsRepository for cross-cutting settings.
// Screens bind to the typed properties below; changing the setting in the
// Settings screen (or externally in the database) notifies every binding.
class AppSettings : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString language READ language NOTIFY languageChanged)
    Q_PROPERTY(QString languageCode READ languageCode NOTIFY languageChanged)
    Q_PROPERTY(QString timezone READ timezone NOTIFY timezoneChanged)
    Q_PROPERTY(QString temperatureUnit READ temperatureUnit NOTIFY temperatureUnitChanged)
    Q_PROPERTY(QString unitSymbol READ unitSymbol NOTIFY temperatureUnitChanged)
    Q_PROPERTY(int brightness READ brightness NOTIFY brightnessChanged)
    Q_PROPERTY(bool nightMode READ nightMode NOTIFY nightModeChanged)

public:
    explicit AppSettings(SettingsRepository *repo, QQmlEngine *engine, QObject *parent = nullptr);

    QString language() const { return mLanguage; }
    QString languageCode() const { return mLanguageCode; }
    QString timezone() const { return mTimezone; }
    QString temperatureUnit() const { return mTemperatureUnit; }
    QString unitSymbol() const;
    int brightness() const { return mBrightness; }
    bool nightMode() const { return mNightMode; }

    // Generic access for settings that have no dedicated property yet.
    Q_INVOKABLE QVariant value(const QString &key) const;
    Q_INVOKABLE bool setValue(const QString &key, const QVariant &value);

    // Formats the current time in the configured time zone.
    Q_INVOKABLE QString formatNow(const QString &format) const;

    // Temperatures are stored canonically in Celsius; conversion happens at
    // display time. Bindings must also reference temperatureUnit or unitSymbol
    // so they re-evaluate when the unit changes.
    Q_INVOKABLE double convertTemperature(double celsius) const;

    // Installs the QTranslator for the current language and refreshes the UI.
    void applyLanguage();

signals:
    void languageChanged();
    void timezoneChanged();
    void temperatureUnitChanged();
    void brightnessChanged();
    void nightModeChanged();

private:
    SettingsRepository *mRepo;
    QQmlEngine *mEngine;

    QTranslator *mTranslator = nullptr;

    QString mLanguage;
    QString mLanguageCode;
    QString mTimezone;
    QString mTemperatureUnit;
    int mBrightness = 100;
    bool mNightMode = false;

    void refresh(const QString &key);
    void refreshAll();

    static QString codeForLanguage(const QString &language);
};

#endif // APPSETTINGS_H
