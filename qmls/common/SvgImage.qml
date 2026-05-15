import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: rootSvg

    property var color
    property string source: ""
    property int fillMode: Image.Stretch

    Image {
        id: svgImage
        height: parent.height
        width: parent.width
        source: rootSvg.source
        fillMode: rootSvg.fillMode
    }

    ColorOverlay {
        source: svgImage
        color: rootSvg.color
        anchors.fill: svgImage

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }
}
