QT += quick quickcontrols2 svg sql virtualkeyboard

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        main.cpp \
        src/schedule/schedulemodel.cpp \
        src/settings/SettingsCategoryModel.cpp \
        src/settings/SettingsItemModel.cpp \
        src/settings/SettingsRepository.cpp \
        src/timer/timermanager.cpp \
        utils/databasemanager.cpp \
        utils/stringhelper.cpp

RESOURCES += qml.qrc \
    resource.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    src/schedule/schedulemodel.h \
    src/settings/SettingCategory.h \
    src/settings/SettingItem.h \
    src/settings/SettingsCategoryModel.h \
    src/settings/SettingsItemModel.h \
    src/settings/SettingsRepository.h \
    src/timer/timermanager.h \
    utils/databasemanager.h \
    utils/stringhelper.h
