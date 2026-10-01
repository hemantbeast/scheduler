// ContentScreen.qml
// Pushed by any settings row with screen_type = 'custom' and
// custom_screen = 'ContentScreen.qml'. Placeholder until the design lands.
import QtQuick 2.15
import QtQuick.Controls 2.15
import "../../../config"
import "../../common"

Page {
    id: root

    background: Rectangle {
        color: StyleConfig.background
    }

    header: NavigationHeader {
        title: qsTr("Contents")
    }

    Label {
        anchors.centerIn: parent
        text: qsTr("Contents")
        color: StyleConfig.textDisabled
        font.pixelSize: 20
    }
}
