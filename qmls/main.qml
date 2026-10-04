import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import "../config"
import "menu"
import "toast"
import "timer"
import "schedule"
import "settings"
import "dashboard"

Window {
    width: 800
    height: 450
    visible: true
    title: qsTr("Timer & Scheduler - QT/QML application")
    color: StyleConfig.background

    property var customScreenRegistry: ({})
    property var settingsItemPage: settingsItemComp

    StackView {
        id: stackView
        initialItem: mainView
        anchors.fill: parent
    }

    Toast {
        id: toastManager
    }

    // Settings screen component for nested screens
    Component {
        id: settingsScreenComp
        SettingsScreen {}
    }

    // Settings item component for nested settings
    Component {
        id: settingsItemComp
        SettingsItemPage {}
    }

    // Main view component
    Component {
        id: mainView

        Item {
            id: mainRoot

            property string selectedMenu: "Timer"
            property int currentIndex: 0

            MenuView {
                id: sideBar
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                onSelected: {
                    mainRoot.selectedMenu = name

                    if (name === "Schedule") {
                        mainRoot.currentIndex = 1
                    }

                    if (name === "Sleep") {
                        mainRoot.currentIndex = 2
                    }

                    if (name === "Setting") {
                        mainRoot.currentIndex = 3
                    }

                    if (name === "Timer") {
                        mainRoot.currentIndex = 0
                    }

                    if (name === "Dashboard") {
                        mainRoot.currentIndex = 4
                    }
                }
            }


            Item {
                id: viewport
                anchors.left: sideBar.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                clip: true

                Item {
                    id: strip
                    width: parent.width
                    height: parent.height * 3

                    y: -mainRoot.currentIndex * mainRoot.height

                    Behavior on y {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutCubic
                        }
                    }

                    TimerNew {
                        width: parent.width
                        height: mainRoot.height
                        y: 0
                    }

                    Schedule {
                        width: parent.width
                        height: mainRoot.height
                        y: mainRoot.height
                    }

                    SleepCurveGraph {
                        width: parent.width
                        height: mainRoot.height
                        y: mainRoot.height * 2
                    }

                    SettingsScreen {
                        width: parent.width
                        height: mainRoot.height
                        y: mainRoot.height * 3
                    }

                    Dashboard {
                        width: parent.width
                        height: mainRoot.height
                        y: mainRoot.height * 4
                    }
                }
            }

            Item {
                height: 50
                anchors.left: sideBar.right
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.leftMargin: 10

                Text {
                    id: timeDisplay
                    // formatNow uses the timezone from Settings; the timer
                    // below refreshes it every second
                    text: appSettings.formatNow("hh:mm ap").toUpperCase()
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                    font {
                        pixelSize: 16
                        weight: Font.Medium
                    }
                }

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: {
                        timeDisplay.text = appSettings.formatNow("hh:mm ap").toUpperCase()
                    }
                }
            }
        }
    }
}
