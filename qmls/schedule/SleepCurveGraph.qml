import QtQuick 2.15
import QtQuick.Shapes 1.15
import QtGraphicalEffects 1.15
import "../../config"

Item {
    Item {
        id: root
        width: 600
        height: 350
        anchors.centerIn: parent

        // Properties to output to your backend/C++ code
        property real tempAsleep: 20.0
        property real tempDeep: 23.0
        property real tempWake: 21.0

        // Core styling definitions
        readonly property real minTemp: 16.0
        readonly property real maxTemp: 30.0
        readonly property color colorHeat: StyleConfig.heatColor
        readonly property color colorCool: StyleConfig.coolColor

        // Helper function to map temperatures directly to visual Y coordinates
        function tempToY(temp) {
            var ratio = (temp - minTemp) / (maxTemp - minTemp);
            return height - (ratio * height);
        }

        // Helper function to map user drag coordinates back to temperature steps
        function yToTemp(yVal) {
            var ratio = (height - yVal) / height;
            var rawTemp = minTemp + (ratio * (maxTemp - minTemp));
            return Math.max(minTemp, Math.min(maxTemp, Math.round(rawTemp * 2) / 2)); // Snap to 0.5 degrees
        }

        // Background Grid lines
        Repeater {
            model: 3
            delegate: Rectangle {
                x: 0
                y: (index + 1) * (root.height / 4)
                width: root.width
                height: 1
                color: StyleConfig.surfaceHover

                Text {
                    // Axis values are Celsius internally; converted for display
                    text: appSettings.convertTemperature(
                              Math.round(root.maxTemp - (index + 1) * ((root.maxTemp - root.minTemp) / 4))
                          ).toFixed(0) + appSettings.unitSymbol
                    color: StyleConfig.textTertiary
                    font.pixelSize: 11
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.bottom: parent.top
                    anchors.bottomMargin: 2
                }
            }
        }

        // Smooth Vector Curve Layer
        Shape {
            id: curveShape
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 4

            layer.effect: LinearGradient {
                start: Qt.point(0, 0)
                end: Qt.point(curveShape.width, 0)

                Gradient {
                    GradientStop { position: 0.0; color: root.colorCool }
                    GradientStop { position: 0.5; color: StyleConfig.purple } // Your Repeat Purple
                    GradientStop { position: 1.0; color: root.colorHeat }
                }
            }

            ShapePath {
                strokeWidth: 4
                strokeColor: "white"
                capStyle: ShapePath.RoundCap
                fillColor: "transparent"

                // Start Position (Node 1)
                startX: node1.x + 12
                startY: node1.y + 12

                // Curve Segment to Node 2, using cubic bezier handle calculations
                PathCubic {
                    x: node2.x + 12
                    y: node2.y + 12
                    control1X: (node1.x + node2.x) / 2
                    control1Y: node1.y + 12
                    control2X: (node1.x + node2.x) / 2
                    control2Y: node2.y + 12
                }

                // Curve Segment to Node 3
                PathCubic {
                    x: node3.x + 12
                    y: node3.y + 12
                    control1X: (node2.x + node3.x) / 2
                    control1Y: node2.y + 12
                    control2X: (node2.x + node3.x) / 2
                    control2Y: node3.y + 12
                }
            }
        }

        // --- INTERACTIVE KNOBS (NODES) ---

        // Node 1: Falling Asleep (Left)
        Rectangle {
            id: node1
            x: (root.width * 0.15) - 12
            y: root.tempToY(root.tempAsleep) - 12
            width: 24; height: 24; radius: 12
            color: StyleConfig.textPrimary
            border.color: root.colorCool; border.width: 3

            MouseArea {
                anchors.fill: parent; drag.target: parent; drag.axis: Drag.YAxis
                drag.minimumY: -12; drag.maximumY: root.height - 12
                onPositionChanged: root.tempAsleep = root.yToTemp(node1.y + 12)
            }
        }

        // Node 2: Deep Sleep (Middle)
        Rectangle {
            id: node2
            x: (root.width * 0.50) - 12
            y: root.tempToY(root.tempDeep) - 12
            width: 24; height: 24; radius: 12
            color: StyleConfig.textPrimary
            border.color: StyleConfig.purple; border.width: 3

            MouseArea {
                anchors.fill: parent; drag.target: parent; drag.axis: Drag.YAxis
                drag.minimumY: -12; drag.maximumY: root.height - 12
                onPositionChanged: root.tempDeep = root.yToTemp(node2.y + 12)
            }
        }

        // Node 3: Waking Up (Right)
        Rectangle {
            id: node3
            x: (root.width * 0.85) - 12
            y: root.tempToY(root.tempWake) - 12
            width: 24; height: 24; radius: 12
            color: StyleConfig.textPrimary
            border.color: root.colorHeat; border.width: 3

            MouseArea {
                anchors.fill: parent; drag.target: parent; drag.axis: Drag.YAxis
                drag.minimumY: -12; drag.maximumY: root.height - 12
                onPositionChanged: root.tempWake = root.yToTemp(node3.y + 12)
            }
        }

        // --- TIMELINE LABELS (BOTTOM) ---
        Row {
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -25

            Text { width: root.width * 0.33; text: qsTr("Asleep") + "\n" + appSettings.convertTemperature(root.tempAsleep).toFixed(1) + appSettings.unitSymbol; color: StyleConfig.textSecondary; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter }
            Text { width: root.width * 0.34; text: qsTr("Deep Sleep") + "\n" + appSettings.convertTemperature(root.tempDeep).toFixed(1) + appSettings.unitSymbol; color: StyleConfig.textSecondary; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter }
            Text { width: root.width * 0.33; text: qsTr("Wake Up") + "\n" + appSettings.convertTemperature(root.tempWake).toFixed(1) + appSettings.unitSymbol; color: StyleConfig.textSecondary; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter }
        }
    }
}
