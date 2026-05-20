import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15

Item {
    Shape {
        id: timerRing
        anchors.centerIn: parent
        width: 250; height: 250
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            strokeColor: "#333333"
            strokeWidth: 10
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: 125; centerY: 125
                radiusX: 110; radiusY: 110
                startAngle: -90
                sweepAngle: 360
            }
        }

        ShapePath {
            strokeColor: "#007acc"
            strokeWidth: 10
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                id: progressArc
                centerX: 125; centerY: 125
                radiusX: 110; radiusY: 110
                startAngle: -90
                sweepAngle: 0 // This will animate

                Behavior on sweepAngle {
                    NumberAnimation { duration: 1000; easing.type: Easing.InOutQuad }
                }
            }
        }

        // Pulsing Glow Effect
        Rectangle {
            anchors.centerIn: parent
            width: 220; height: 220
            radius: 110
            color: "#007acc"
            opacity: 0.1

            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { from: 0.95; to: 1.05; duration: 2000; easing.type: Easing.SineInOut }
                NumberAnimation { from: 1.05; to: 0.95; duration: 2000; easing.type: Easing.SineInOut }
            }
        }

        Text {
            id: timerText
            anchors.centerIn: parent
            text: "00:45"
            color: "white"
            font.pixelSize: 48
            font.weight: Font.Light
        }
    }
}
