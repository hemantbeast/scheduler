import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    property int currentMode: 0
    property var modeColors: ["#FF5F00", "#00B4FF", "#00FFC2"]
    property var modeNames: ["HEAT", "COOL", "DRY"]
    property bool isTimerRunning: false

    signal modeSelected(int index)

    width: 320
    height: 40
    radius: height / 2
    color: "#161616"
    border.color: "#282828"
    border.width: 1

    Rectangle {
        id: activeIndicator
        width: root.width / root.modeNames.length - 8
        height: root.height - 8
        radius: height / 2
        anchors.verticalCenter: parent.verticalCenter
        color: root.modeColors[root.currentMode]
        x: 4 + (root.currentMode * (root.width / root.modeNames.length))

        Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        Behavior on color {
            ColorAnimation { duration: 300 }
        }
    }

    Row {
        anchors.fill: parent

        Repeater {
            model: root.modeNames

            Item {
                width: root.width / root.modeNames.length
                height: root.height

                Text {
                    text: modelData
                    anchors.centerIn: parent
                    color: root.currentMode === index ? "white" : "#8A8A8A"
                    scale: root.currentMode === index ? 1.05 : 1.0
                    font {
                        pixelSize: 11
                        letterSpacing: 1.5
                        bold: true
                    }

                    Behavior on color {
                        ColorAnimation { duration: 250 }
                    }

                    Behavior on scale {
                        NumberAnimation { duration: 200 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (root.isTimerRunning) {
                            root.modeSelected(index)
                        }
                    }
                }
            }
        }
    }
}
