// InputSetting.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../config"

Item {
    id: root
    width: parent.width
    height: 60

    required property string label
    required property string text
    required property int    maxLength

    signal committed(string newText)

    RowLayout {
        anchors.fill: parent

        Label {
            text: root.label
            font.pixelSize: 20
            font.weight: Font.Normal
            color: StyleConfig.textPrimary
            Layout.fillWidth: true
        }

        Label {
            text: root.text !== "" ? root.text : "—"
            font.pixelSize: 20
            color: StyleConfig.textSecondary
        }
    }

    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1
        color: StyleConfig.surfaceHover
    }

    MouseArea {
        anchors.fill: parent
        onClicked: popup.open()
    }

    Popup {
        id: popup
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: 360
        height: 140
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: StyleConfig.surface
            radius: 16
        }

        contentItem: RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            TextField {
                id: field
                text: root.text
                maximumLength: root.maxLength
                selectByMouse: true
                Layout.fillWidth: true
                Layout.preferredHeight: 48

                font.pixelSize: 18
                color: StyleConfig.textPrimary

                background: Rectangle {
                    color: StyleConfig.surfaceHover
                    radius: 8
                }

                onAccepted: {
                    root.committed(field.text)
                    popup.close()
                }
            }

            ItemDelegate {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48

                background: Rectangle {
                    color: tickMouseArea.pressed ? Qt.darker(StyleConfig.accent, 1.2) : StyleConfig.accent
                    radius: 8
                }

                contentItem: Label {
                    text: "✓"
                    font.pixelSize: 24
                    color: StyleConfig.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    id: tickMouseArea
                    anchors.fill: parent
                    onClicked: {
                        root.committed(field.text)
                        popup.close()
                    }
                }
            }
        }
    }
}
