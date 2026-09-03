// SettingsScreen.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../common"

Page {
    id: root
    title: qsTr("Settings")

    background: Rectangle { color: "black" }

    ColumnLayout {
        spacing: 8
        anchors.topMargin: 20
        anchors.fill: parent

        Label {
            text: qsTr("Settings")
            font.pixelSize: 24
            font.weight: Font.Normal
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        ListView {
            id: categoryList
            model: categoryModel        // SettingsCategoryModel*
            clip: true
            Layout.fillHeight: true
            Layout.fillWidth: true

            delegate: ItemDelegate {
                width: parent.width
                height: 56

                background: Rectangle {
                    color: "transparent"
                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: 1
                        color: "#2a2a2a"
                    }
                }

                contentItem: RowLayout {
                    spacing: 10
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: 16
                        rightMargin: 12
                    }

                    Label {
                        text: model.label
                        font.pixelSize: 20
                        font.weight: Font.Normal
                        color: "white"
                        Layout.fillWidth: true
                    }

                    SvgImage {
                        height: 20
                        width: 20
                        source: "../../images/right_arrow.svg"
                        color: "white"
                        Layout.alignment: Qt.AlignRight
                    }
                }

                onClicked: {
                    itemModel.categoryId = model.id

                    stackView.push("SettingsItemPage.qml", {
                                       "pageTitle": model.label
                                   })
                }
            }
        }
    }
}
