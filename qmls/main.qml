import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import "menu"
import "toast"

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
            anchors.fill: parent

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
                anchors.left: sideBar.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                Loader {
                    anchors.fill: parent
                    source: {
                        if (mainRoot.selectedMenu === "Timer") return "timer/TimerNew.qml"
                        if (mainRoot.selectedMenu === "Schedule") return "schedule/Schedule.qml"
                        return ""
                    }
                }
            }
        }
    }
}
