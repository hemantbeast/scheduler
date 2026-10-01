import QtQuick 2.15
import QtQuick.Controls 2.15
import "../../config"

Rectangle {
    id: navigationHeader
    height: 60
    color: StyleConfig.surfaceAlt

    property string title: ""
    property var titleColor

    // Back button
    Rectangle {
        id: backBtn
        width: 40; height: 40
        color: "transparent"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 15
        opacity: backMouseArea.pressed ? 0.7 : 1.0

        SvgImage {
            height: 27; width: 27
            color: StyleConfig.textPrimary
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
            color: navigationHeader.titleColor || StyleConfig.textPrimary
            anchors.centerIn: parent
            font {
                pixelSize: 20
                weight: Font.Bold
            }
        }
    }
}
