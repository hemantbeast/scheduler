import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import QtGraphicalEffects 1.15

Item {
    property int currentMode: 0
    property var modeColors: ["#FF5F00", "#00B4FF", "#00FFC2"]
    property var modeNames: ["HEAT", "COOL", "DRY"]

    // Rectangle {
    //     id: bgGlow
    //     anchors.fill: parent

    //     RadialGradient {
    //         anchors.fill: parent
    //         gradient: Gradient {
    //             GradientStop { position: 0.0; color: Qt.alpha(modeColors[currentMode], 0.15) }
    //             GradientStop { position: 0.7; color: "transparent" }
    //         }

    //         Behavior on gradient { PropertyAnimation { duration: 1000 } }
    //     }
    // }

    // Mode Text
    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 40
        spacing: 50

        Repeater {
            model: modeNames
            Text {
                text: modelData
                color: currentMode === index ? modeColors[index] : "#555555"
                scale: currentMode === index ? 1.1 : 1.0

                font {
                    pixelSize: 10
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

    // Center dial
    Rectangle {
        id: dialContainer
        height: 250; width: 250
        color: "transparent"
        anchors.centerIn: parent

        Rectangle {
            id: pulseRing
            width: 237.5; height: 237.5
            anchors.centerIn: dialContainer
            radius: 118.75
            color: "transparent"
            border.color: modeColors[currentMode]
            border.width: 2
            opacity: 0.2

            SequentialAnimation on scale {
                loops: Animation.Infinite
                running: true
                NumberAnimation { from: 1.0; to: 1.08; duration: 2000; easing.type: Easing.SineInOut }
                NumberAnimation { from: 1.08; to: 1.0; duration: 2000; easing.type: Easing.SineInOut }
            }

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: true
                NumberAnimation { from: 0.1; to: 0.3; duration: 2000; easing.type: Easing.SineInOut }
                NumberAnimation { from: 0.3; to: 0.1; duration: 2000; easing.type: Easing.SineInOut }
            }
        }

        Repeater {
            model: 40 // Number of ticks
            delegate: Rectangle {
                width: 1.25; height: 6.25
                color: "#444"
                x: 125 + 112.5 * Math.cos((index * (270/40) - 225) * Math.PI / 180) - width/2
                y: 125 + 112.5 * Math.sin((index * (270/40) - 225) * Math.PI / 180) - height/2
                rotation: index * (270/40) - 135
            }
        }

        // Background Outer Ring (Subtle segments)
        // Shape {
        //     anchors.fill: parent
        //     layer.enabled: true
        //     layer.samples: 8

        //     ShapePath {
        //         strokeColor: "#222"
        //         strokeWidth: 20
        //         fillColor: "transparent"
        //         capStyle: ShapePath.RoundCap
        //         dashPattern: [1, 4]

        //         PathAngleArc {
        //             centerX: 200; centerY: 200
        //             radiusX: 180; radiusY: 180
        //             startAngle: -225; sweepAngle: 270
        //         }
        //     }
        // }

        // Animated "Mode" Progress Ring
        Shape {
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 8

            ShapePath {
                strokeWidth: 13.75; fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                strokeColor: modeColors[currentMode]

                Behavior on strokeColor {
                    ColorAnimation { duration: 400 }
                }

                PathAngleArc {
                    id: heatArc
                    centerX: 125; centerY: 125
                    radiusX: 112.5; radiusY: 112.5
                    startAngle: -225
                    sweepAngle: 180 // Linked to timer progress

                    Behavior on sweepAngle {
                        NumberAnimation {
                            duration: 600; easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }

        // Inner Glow & Display
        Rectangle {
            width: 187.5
            height: 187.5
            radius: 93.75
            color: "#1a1a1a"
            anchors.centerIn: parent

            border {
                color: "#2a2a2a"
                width: 1.25
            }

            ColumnLayout {
                spacing: 3
                anchors.centerIn: parent

                Text {
                    text: qsTr("TIME LEFT")
                    color: "#666"
                    Layout.alignment: Qt.AlignHCenter
                    font {
                        pixelSize: 9
                        letterSpacing: 1.25
                    }
                }

                Text {
                    id: timeDisplay
                    text: "24:00"
                    color: "white"
                    font {
                        pixelSize: 50
                        weight: Font.Light
                    }
                }

                Text {
                    text: qsTr("MINUTES")
                    color: modeColors[currentMode]
                    Layout.alignment: Qt.AlignHCenter
                    font {
                        pixelSize: 10
                        weight: Font.Bold
                    }
                }

                Rectangle {
                    width: 75; height: 1; color: "#333"
                    Layout.alignment: Qt.AlignHCenter
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 1
                    Text {
                        text: qsTr("NEXT UP")
                        color: "#555"
                        Layout.alignment: Qt.AlignHCenter
                        font {
                            pixelSize: 6; bold: true
                        }
                    }
                    Text {
                        text: "Project Review"
                        color: "#AAA"
                        Layout.alignment: Qt.AlignHCenter
                        font {
                            pixelSize: 9; italic: true
                        }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: heatArc.sweepAngle = (heatArc.sweepAngle + 45) % 271
        }
    }
}
