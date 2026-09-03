#ifndef SETTINGSTRANSLATIONS_H
#define SETTINGSTRANSLATIONS_H

#include <QStringList>

// Labels and descriptions stored in the settings database cannot be seen by
// lupdate, so the known strings are listed here to be harvested for
// translation. At runtime the models pass the DB strings through
// QCoreApplication::translate() with the same contexts.
namespace SettingsTranslations {

inline QStringList categoryLabels()
{
    return {
        QT_TRANSLATE_NOOP("SettingsCategories", "General Settings"),
        QT_TRANSLATE_NOOP("SettingsCategories", "Display"),
        QT_TRANSLATE_NOOP("SettingsCategories", "Audio"),
        QT_TRANSLATE_NOOP("SettingsCategories", "Network"),
    };
}

inline QStringList itemLabels()
{
    return {
        QT_TRANSLATE_NOOP("SettingsItems", "Language"),
        QT_TRANSLATE_NOOP("SettingsItems", "Time Zone"),
        QT_TRANSLATE_NOOP("SettingsItems", "Auto Update"),
        QT_TRANSLATE_NOOP("SettingsItems", "Firmware Version"),
        QT_TRANSLATE_NOOP("SettingsItems", "Brightness"),
        QT_TRANSLATE_NOOP("SettingsItems", "Contrast"),
        QT_TRANSLATE_NOOP("SettingsItems", "Color Temperature"),
        QT_TRANSLATE_NOOP("SettingsItems", "Night Mode"),
        QT_TRANSLATE_NOOP("SettingsItems", "Temperature Unit"),
        QT_TRANSLATE_NOOP("SettingsItems", "Master Volume"),
        QT_TRANSLATE_NOOP("SettingsItems", "Audio Output"),
        QT_TRANSLATE_NOOP("SettingsItems", "Audio Mode"),
        QT_TRANSLATE_NOOP("SettingsItems", "Wi-Fi"),
        QT_TRANSLATE_NOOP("SettingsItems", "Hostname"),
        QT_TRANSLATE_NOOP("SettingsItems", "DNS Timeout"),
    };
}

inline QStringList itemDescriptions()
{
    return {
        QT_TRANSLATE_NOOP("SettingsItems", "App display language"),
        QT_TRANSLATE_NOOP("SettingsItems", "IANA timezone identifier"),
        QT_TRANSLATE_NOOP("SettingsItems", "Automatically install firmware updates"),
        QT_TRANSLATE_NOOP("SettingsItems", "Temperature display unit"),
        QT_TRANSLATE_NOOP("SettingsItems", "Device name on the local network"),
        QT_TRANSLATE_NOOP("SettingsItems", "Timeout for DNS resolution requests"),
    };
}

} // namespace SettingsTranslations

#endif // SETTINGSTRANSLATIONS_H
