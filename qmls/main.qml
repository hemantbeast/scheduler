import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import "menu"
import "toast"
import "timer"
import "schedule"

Window {
    width: 800
    height: 450
    visible: true
    title: qsTr("Timer & Scheduler")
    color: "#121212"

    StackView {
        id: stackView
        initialItem: mainView
        anchors.fill: parent
    }

    Toast {
        id: toastManager
    }

    Component {
        id:mainView

        Item {
            id: mainRoot

            property string selectedMenu: "Timer"

            MenuView {
                id: sideBar
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                onSelected: {
                    mainRoot.selectedMenu = name
                }
            }

            Item {
                clip: true
                anchors.left: sideBar.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                TimerNew {
                    id: timerPage
                    width: parent.width
                    height: parent.height
                    y: mainRoot.selectedMenu === "Timer" ? 0 : -parent.height
                    opacity: mainRoot.selectedMenu === "Timer" ? 1.0 : 0.0

                    Behavior on y {
                        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 300 }
                    }
                }

                Schedule {
                    id: schedulePage
                    width: parent.width
                    height: parent.height
                    y: mainRoot.selectedMenu === "Schedule" ? 0 : parent.height
                    opacity: mainRoot.selectedMenu === "Schedule" ? 1.0 : 0.0

                    Behavior on y {
                        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 300 }
                    }
                }
            }
        }
    }
}
