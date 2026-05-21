import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import QtGraphicalEffects 1.15

Item {
    id: timerScreen

    property var modeColors: ["#FF5F00", "#00B4FF", "#00FFC2"]
    property var modeNames: ["HEAT", "COOL", "DRY"]

    property real progressPercentage: timerManager.secondsRemaining / timerManager.totalDuration
    property real computedSweepAngle: progressPercentage * 270

    function formatTime(totalSeconds) {
        if (totalSeconds <= 0) return "00:00"

        let minutes = Math.floor(totalSeconds / 60)
        let seconds = totalSeconds % 60

        return (minutes < 10 ? "0" : "") + minutes + ":" + (seconds < 10 ? "0" : "") + seconds
    }

    // Rectangle {
    //     id: bgGlow
    //     anchors.fill: parent

    //     Item {
    //         id: proxySource
    //         anchors.fill: parent
    //         visible: false
    //     }

    //     RadialGradient {
    //         source: proxySource
    //         anchors.fill: parent
    //         horizontalRadius: width / 2
    //         verticalRadius: height / 2
    //         gradient: Gradient {
    //             GradientStop {
    //                 id: coreColor
    //                 position: 0.0

    //                 // Correct syntax: target color string + desired alpha
    //                 color: {
    //                     let baseColor = timerScreen.modeColors[timerManager.currentMode] || "#000000";
    //                     return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.15);
    //                 }

    //                 // Animate the color property directly
    //                 Behavior on color { ColorAnimation { duration: 1000 } }
    //             }

    //             GradientStop {
    //                 position: 0.7
    //                 color: "transparent"
    //             }
    //         }
    //     }
    // }

    // Mode Text
    Rectangle {
        id: segmentedControl
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 40
        width: 320
        height: 40
        radius: height / 2
        color: "#161616"
        border.color: "#282828"
        border.width: 1

        Rectangle {
            id: activeIndicator
            width: segmentedControl.width / timerScreen.modeNames.length - 8
            height: segmentedControl.height - 8
            radius: height / 2
            anchors.verticalCenter: parent.verticalCenter
            color: timerScreen.modeColors[timerManager.currentMode]
            x: 4 + (timerManager.currentMode * (segmentedControl.width / timerScreen.modeNames.length))

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
                model: timerScreen.modeNames

                Item {
                    width: segmentedControl.width / timerScreen.modeNames.length
                    height: segmentedControl.height

                    Text {
                        text: modelData
                        anchors.centerIn: parent
                        color: timerManager.currentMode === index ? "white" : "#8A8A8A"
                        scale: timerManager.currentMode === index ? 1.05 : 1.0
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
                            if (timerManager.secondsRemaining > 0) {
                                timerManager.currentMode = index
                            }
                        }
                    }
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
            border.color: timerScreen.modeColors[timerManager.currentMode]
            border.width: 2
            opacity: 0.2

            SequentialAnimation on scale {
                loops: Animation.Infinite
                running: timerManager.secondsRemaining > 0
                NumberAnimation { from: 1.0; to: 1.08; duration: 2000; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1.08; to: 1.0; duration: 2000; easing.type: Easing.InOutSine }
            }

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: timerManager.secondsRemaining > 0
                NumberAnimation { from: 0.1; to: 0.3; duration: 2000; easing.type: Easing.InOutSine }
                NumberAnimation { from: 0.3; to: 0.1; duration: 2000; easing.type: Easing.InOutSine }
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
                strokeColor: timerScreen.modeColors[timerManager.currentMode]

                Behavior on strokeColor {
                    ColorAnimation { duration: 400 }
                }

                PathAngleArc {
                    id: heatArc
                    centerX: 125; centerY: 125
                    radiusX: 112.5; radiusY: 112.5
                    startAngle: -225
                    sweepAngle: timerScreen.computedSweepAngle // Linked to timer progress

                    Behavior on sweepAngle {
                        NumberAnimation { duration: 300 }
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
                    text: timerManager.secondsRemaining > 0 ? qsTr("TIME LEFT") : qsTr("SYSTEM IDLE")
                    color: "#666"
                    Layout.alignment: Qt.AlignHCenter
                    font {
                        pixelSize: 10
                        letterSpacing: 1.25
                    }
                }

                Text {
                    id: timeDisplay
                    text: timerScreen.formatTime(timerManager.secondsRemaining)
                    color: "white"
                    font {
                        pixelSize: 50
                        weight: Font.Light
                    }
                }

                Text {
                    text: timerManager.secondsRemaining < 60 ? qsTr("SECONDS") : qsTr("MINUTES")
                    color: timerScreen.modeColors[timerManager.currentMode]
                    visible: timerManager.secondsRemaining > 0
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
                            pixelSize: 8; bold: true
                        }
                    }
                    Text {
                        text: timerManager.nextScheduleName
                        color: "#AAA"
                        Layout.alignment: Qt.AlignHCenter
                        font {
                            pixelSize: 10; italic: true
                        }
                    }
                }
            }
        }
    }

    Button {
        id: stopBtn
        implicitWidth: 44
        implicitHeight: 44

        anchors.top: dialContainer.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter

        visible: timerManager.secondsRemaining > 0
        onClicked: timerManager.stopTimer()

        background: Rectangle {
            radius: width / 2
            color: "#424242"
            scale: stopBtn.pressed ? 0.9 : 1.0
            opacity: stopBtn.pressed ? 0.7 : 1.0

            Behavior on scale {
                NumberAnimation { duration: 50 }
            }
        }

        contentItem: Item {
            anchors.fill: parent

            Rectangle {
                width: 14
                height: 14
                radius: 2
                anchors.centerIn: parent
                color: "#EF4444"
                opacity: stopBtn.pressed ? 0.7 : 1.0
                scale: stopBtn.pressed ? 0.9 : 1.0

                Behavior on scale {
                    NumberAnimation { duration: 50 }
                }
            }
        }
    }
}
