// ToggleSetting.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../config"

Item {
    id: root
    width: parent.width
    height: 60

    required property string label
    required property bool   checked

    signal toggled(bool isOn)

    RowLayout {
        anchors.fill: parent

        Label {
            text: root.label
            font.pixelSize: 20
            font.weight: Font.Normal
            color: StyleConfig.textPrimary
            Layout.fillWidth: true
        }

        Switch {
            id: toggle
            checked: root.checked

            indicator: Rectangle {
                implicitWidth:  64
                implicitHeight: 32
                radius: 16
                color: toggle.checked ? StyleConfig.accent : StyleConfig.textDisabled
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Rectangle {
                    x: toggle.checked
                       ? parent.width - width - 3
                       : 3
                    anchors.verticalCenter: parent.verticalCenter
                    width:  26
                    height: 26
                    radius: 13
                    color: StyleConfig.textPrimary

                    Behavior on x {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            onToggled: root.toggled(checked)
        }
    }

    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1
        color: StyleConfig.surfaceHover
    }
}
