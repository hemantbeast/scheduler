// ContentScreen.qml
// Pushed by any settings row with screen_type = 'custom' and
// custom_screen = 'ContentScreen.qml'. Placeholder until the design lands.
import QtQuick 2.15
import QtQuick.Controls 2.15
import "../../common"

Page {
    id: root

    background: Rectangle {
        color: "black"
    }

    header: NavigationHeader {
        title: "Contents"
    }

    Label {
        anchors.centerIn: parent
        text: "Contents"
        color: "#444444"
        font.pixelSize: 20
    }
}
