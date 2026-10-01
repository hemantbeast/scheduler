import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../config"
import "../common"

Page {
    id: root

    property string pageTitle: ""

    background: Rectangle {
        color: StyleConfig.background
    }

    header: NavigationHeader {
        id: navigation
        title: root.pageTitle
        Layout.alignment: Qt.AlignTop
    }

    ListView {
        id: settingsList
        anchors.fill: parent
        clip: true
        model: itemModel            // SettingsItemModel*
        spacing: 0

        delegate: SettingDelegate {
            onKeyValueChanged: (key, val) => itemModel.setValue(key, val)
        }

        // Empty state
        Label {
            anchors.centerIn: parent
            visible: settingsList.count === 0
            text: qsTr("No settings available")
            color: StyleConfig.textDisabled
            font.pixelSize: 20
        }
    }
}
