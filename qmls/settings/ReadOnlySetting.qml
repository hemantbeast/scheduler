// ReadOnlySetting.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

RowLayout {
    id: root
    width: parent.width

    required property string label
    required property var    displayValue

    Label {
        text: root.label
        font.pixelSize: 20
        color: "white"
        Layout.fillWidth: true
    }

    Label {
        text: root.displayValue !== undefined ? root.displayValue : "—"
        font.pixelSize: 18
        color: "#999999"
        horizontalAlignment: Text.AlignRight
    }
}
