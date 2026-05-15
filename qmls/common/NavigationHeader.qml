import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: navigationHeader
    height: 60
    color: "#252526"

    property string title: ""
    property var titleColor

    // Back button
    Rectangle {
        id: backBtn
        width: 60; height: 60
        color: "transparent"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 5
        opacity: backMouseArea.pressed ? 0.7 : 1.0

        SvgImage {
            height: 32; width: 32
            color: "white"
            source: "../../images/back.svg"
            anchors.centerIn: parent
            scale: backMouseArea.pressed ? 0.97 : 1.0

            Behavior on scale {
                NumberAnimation { duration: 50 }
            }
        }

        MouseArea {
            id: backMouseArea
            anchors.fill: parent
            onClicked: stackView.pop()
        }
    }

    // Title view
    Item {
        anchors.fill: parent

        Label {
            id: lblTitle
            text: navigationHeader.title
            color: navigationHeader.titleColor || "white"
            anchors.centerIn: parent
            font {
                pointSize: 12
                weight: Font.Bold
            }
        }
    }
}
