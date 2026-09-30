QT += quick quickcontrols2 svg sql virtualkeyboard

# You can make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Qt 5.15 has no embed_translations feature: run lrelease at qmake time and
# embed the generated .qm files via translations/i18n.qrc under :/i18n.
# Re-run qmake (or lrelease manually) after editing the .ts files.
TS_FILES = $$files($$PWD/translations/*.ts)
system($$[QT_INSTALL_BINS]/lrelease.exe -silent $$TS_FILES)

TRANSLATIONS += \
    translations/scheduler_en.ts \
    translations/scheduler_hi.ts \
    translations/scheduler_kn.ts \
    translations/scheduler_ta.ts \
    translations/scheduler_ko.ts

SOURCES += \
        main.cpp \
        src/dashboard/dashboardbackend.cpp \
        src/schedule/schedulemodel.cpp \
        src/settings/AppSettings.cpp \
        src/settings/SettingsCategoryModel.cpp \
        src/settings/SettingsItemModel.cpp \
        src/settings/SettingsRepository.cpp \
        src/timer/timermanager.cpp \
        utils/databasemanager.cpp \
        utils/dbpathresolver.cpp \
        utils/stringhelper.cpp

RESOURCES += qml.qrc \
    resource.qrc \
    translations/i18n.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    src/dashboard/dashboardbackend.h \
    src/schedule/schedulemodel.h \
    src/settings/AppSettings.h \
    src/settings/SettingCategory.h \
    src/settings/SettingItem.h \
    src/settings/SettingsCategoryModel.h \
    src/settings/SettingsItemModel.h \
    src/settings/SettingsRepository.h \
    src/settings/SettingsTranslations.h \
    src/timer/timermanager.h \
    utils/databasemanager.h \
    utils/dbpathresolver.h \
    utils/stringhelper.h
