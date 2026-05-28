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
    property bool isFlashing: false

    function formatTime(totalSeconds) {
        if (totalSeconds <= 0) return "00:00"

        let minutes = Math.floor(totalSeconds / 60)
        let seconds = totalSeconds % 60

        return (minutes < 10 ? "0" : "") + minutes + ":" + (seconds < 10 ? "0" : "") + seconds
    }

    TimerBackground {
        anchors.fill: parent
        currentColor: timerScreen.modeColors[timerManager.currentMode]
        isActive: timerManager.secondsRemaining > 0
    }

    TimerModeText {
        id: segmentedControl
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 40
        currentMode: timerManager.currentMode
        modeColors: timerScreen.modeColors
        modeNames: timerScreen.modeNames
        isTimerRunning: timerManager.secondsRemaining > 0

        onModeSelected: {
            timerManager.currentMode = index
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

        Shape {
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 8

            ShapePath {
                strokeWidth: 13.75; fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                strokeColor: timerScreen.isFlashing ? "white" : timerScreen.modeColors[timerManager.currentMode]

                Behavior on strokeColor {
                    ColorAnimation { duration: 400 }
                }

                PathAngleArc {
                    id: heatArc
                    centerX: 125; centerY: 125
                    radiusX: 112.5; radiusY: 112.5
                    startAngle: -225
                    sweepAngle: timerScreen.computedSweepAngle

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
                    visible: timerManager.activeScheduleName !== ""

                    Text {
                        text: qsTr("RUNNING")
                        color: "#555"
                        Layout.alignment: Qt.AlignHCenter
                        font {
                            pixelSize: 8; bold: true
                        }
                    }
                    Text {
                        text: timerManager.activeScheduleName
                        color: timerScreen.modeColors[timerManager.currentMode]
                        Layout.alignment: Qt.AlignHCenter
                        font {
                            pixelSize: 10; italic: true; bold: true
                        }
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 1
                    visible: timerManager.activeScheduleName === "" && timerManager.nextScheduleName !== ""

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

    SequentialAnimation {
        id: completionFlash
        loops: 3

        ScriptAction { script: timerScreen.isFlashing = true }
        PauseAnimation { duration: 250 }
        ScriptAction { script: timerScreen.isFlashing = false }
        PauseAnimation { duration: 250 }
    }

    Connections {
        target: timerManager
        function onTimerCompleted() {
            completionFlash.start()
            toastManager.createMessage("Schedule completed!", {
                type: "success",
                position: Qt.TopEdge,
                theme: "Color"
            })
        }
    }
}
