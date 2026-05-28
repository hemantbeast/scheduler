import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: root
    property string currentColor: "#FF5F00"
    property bool isActive: false

    RadialGradient {
        anchors.fill: parent
        horizontalRadius: width / 2
        verticalRadius: height / 2
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: {
                    let r = parseInt(currentColor.substr(1, 2), 16) / 255
                    let g = parseInt(currentColor.substr(3, 2), 16) / 255
                    let b = parseInt(currentColor.substr(5, 2), 16) / 255
                    return Qt.rgba(r, g, b, root.isActive ? 0.15 : 0.08)
                }
                Behavior on color { ColorAnimation { duration: 800 } }
            }
            GradientStop {
                position: 0.7
                color: "transparent"
            }
        }

        SequentialAnimation on scale {
            loops: Animation.Infinite
            running: root.isActive
            NumberAnimation { from: 1.0; to: 1.05; duration: 2500; easing.type: Easing.InOutSine }
            NumberAnimation { from: 1.05; to: 1.0; duration: 2500; easing.type: Easing.InOutSine }
        }
    }
}
