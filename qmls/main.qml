import QtQuick 2.15
import QtQuick.Window 2.15
import "menu" as Menu

Window {
    width: 1280
    height: 720
    visible: true
    title: qsTr("Timer & Scheduler")
    color: "#121212"

    property string selectedMenu: "Timer"

    Menu.MenuView {
        id: sideBar
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        onSelected: {
            selectedMenu = name
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
                if (selectedMenu === "Timer") return "timer/TimerNew.qml"
                if (selectedMenu === "Schedule") return "schedule/Schedule.qml"
                return ""
            }
        }
    }
}
