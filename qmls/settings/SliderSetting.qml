// SliderSetting.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    width: parent.width
    height: 60

    required property string label
    required property string unit
    required property real   value
    required property real   minVal
    required property real   maxVal
    required property real   stepSize

    signal committed(real newVal)

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
            text: root.value.toFixed(root.stepSize < 1 ? 1 : 0) + " " + root.unit
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
        width: 360
        height: 200
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#1e1e1e"
            radius: 16
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            Label {
                text: root.label
                font.pixelSize: 20
                font.weight: Font.Normal
                color: "#ffffff"
                Layout.alignment: Qt.AlignHCenter
            }

            Slider {
                id: slider
                Layout.fillWidth: true
                from: root.minVal
                to: root.maxVal
                stepSize: root.stepSize
                value: root.value
                snapMode: Slider.SnapAlways

                handle: Rectangle {
                    x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: 26
                    implicitHeight: 26
                    radius: 13
                    color: slider.pressed ? "#d0d0d0" : "#ffffff"
                    border.color: "#999999"
                    border.width: 1
                }

                background: Rectangle {
                    x: slider.leftPadding
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitHeight: 6
                    implicitWidth: 200
                    width: slider.availableWidth
                    height: implicitHeight
                    radius: 3
                    color: "#404040"

                    Rectangle {
                        width: slider.visualPosition * parent.width
                        height: parent.height
                        color: "#4a9eff"
                        radius: 3
                    }
                }

                onPressedChanged: {
                    if (!pressed)
                        root.committed(value)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: root.minVal + " " + root.unit
                    font.pixelSize: 14
                    color: "#999999"
                }
                Item { Layout.fillWidth: true }
                Label {
                    text: slider.value.toFixed(root.stepSize < 1 ? 1 : 0) + " " + root.unit
                    font.pixelSize: 15
                    color: "#4a9eff"
                    font.weight: Font.Medium
                }
                Item { Layout.fillWidth: true }
                Label {
                    text: root.maxVal + " " + root.unit
                    font.pixelSize: 14
                    color: "#999999"
                }
            }
        }
    }
}
