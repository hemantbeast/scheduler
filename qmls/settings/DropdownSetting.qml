// DropdownSetting.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

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
            color: "#ffffff"
            Layout.fillWidth: true
        }

        Label {
            text: root.currentValue
            font.pixelSize: 20
            color: "#999999"
        }
    }

    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1
        color: "#2a2a2a"
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
            color: "#1e1e1e"
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
                    color: "#ffffff"
                }

                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    height: 1
                    color: "#333333"
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
                               ? "#2a3a4a" : "transparent"
                        Rectangle {
                            anchors {
                                left: parent.left; right: parent.right
                                bottom: parent.bottom
                            }
                            height: 1
                            color: "#2a2a2a"
                            visible: index < root.options.length - 1
                        }
                    }

                    contentItem: Label {
                        text: modelData
                        font.pixelSize: 16
                        font.weight: modelData === root.currentValue
                                     ? Font.Bold : Font.Normal
                        color: modelData === root.currentValue
                               ? "#4a9eff" : "#ffffff"
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
