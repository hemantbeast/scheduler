// DropdownSetting.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../config"

Item {
    id: root
    width: parent.width
    height: 60

    required property string label
    required property string currentValue
    required property var    options

    signal selected(string value)

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
            text: root.currentValue
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
        width: 320
        height: Math.min(options.length * 56 + 64, 480)
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: StyleConfig.surface
            radius: 16
        }

        contentItem: Column {
            width: parent.width
            spacing: 0

            Item {
                width: parent.width
                height: 56

                Label {
                    anchors.centerIn: parent
                    text: root.label
                    font.pixelSize: 20
                    font.weight: Font.Normal
                    color: StyleConfig.textPrimary
                }

                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    height: 1
                    color: StyleConfig.border
                }
            }

            ListView {
                id: optionsList
                width: parent.width
                height: popup.height - 56
                model: root.options
                clip: true

                delegate: ItemDelegate {
                    width: parent.width
                    height: 56

                    background: Rectangle {
                        radius: modelData === root.currentValue ? 5 : 0
                        color: modelData === root.currentValue
                               ? StyleConfig.surfaceHover : "transparent"
                        Rectangle {
                            anchors {
                                left: parent.left; right: parent.right
                                bottom: parent.bottom
                            }
                            height: 1
                            color: StyleConfig.surfaceHover
                            visible: index < root.options.length - 1
                        }
                    }

                    contentItem: Label {
                        text: modelData
                        font.pixelSize: 16
                        font.weight: modelData === root.currentValue
                                     ? Font.Bold : Font.Normal
                        color: modelData === root.currentValue
                               ? StyleConfig.accent : StyleConfig.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        root.selected(modelData)
                        popup.close()
                    }
                }
            }
        }
    }
}
