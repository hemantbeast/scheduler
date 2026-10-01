// ReadOnlySetting.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../config"

RowLayout {
    id: root
    width: parent.width

    required property string label
    required property var    displayValue

    Label {
        text: root.label
        font.pixelSize: 20
        color: StyleConfig.textPrimary
        Layout.fillWidth: true
    }

    Label {
        text: root.displayValue !== undefined ? root.displayValue : "—"
        font.pixelSize: 18
        color: StyleConfig.textSecondary
        horizontalAlignment: Text.AlignRight
    }
}
