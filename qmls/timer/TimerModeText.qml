import QtQuick 2.15

Item {
    property int currentMode: 0
    property var modeColors
    property var modeNames

    Row {
        spacing: 50

        Repeater {
            model: modeNames
            Text {
                text: modelData
                color: currentMode === index ? modeColors[index] : "#555555"
                scale: currentMode === index ? 1.1 : 1.0

                font {
                    pixelSize: 14
                    letterSpacing: 1.5
                    bold: true
                }

                Behavior on color {
                    ColorAnimation { duration: 400 }
                }

                Behavior on scale {
                    NumberAnimation { duration: 200 }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: currentMode = index
                }
            }
        }
    }

}
