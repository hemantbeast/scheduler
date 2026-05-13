import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "../../config" as Config

Item {
    id: scheduleRoot

    ColumnLayout {
        spacing: 0
        anchors.fill: parent

        Rectangle {
            id: addBtn
            height: 60; width: 60
            radius: 30
            color: "transparent"
            Layout.alignment: Qt.AlignTop | Qt.AlignRight

            layer.enabled: true
            layer.samples: 8
            opacity: addMouseArea.pressed ? 0.7 : 1.0

            Image {
                id: imgAdd
                height: 40; width: 40
                source: "../../images/add.svg"
                anchors.centerIn: parent
            }

            ColorOverlay {
                source: imgAdd
                anchors.fill: imgAdd
                color: "#fff"
            }

            MouseArea {
                id: addMouseArea
                anchors.fill: parent
                onClicked: {

                }
            }
        }

        ListView {
            model: schedleItems
            delegate: scheduleDelegate
            clip: true
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    ListModel {
        id: schedleItems
        ListElement {
            name: "Living Room"
            mode: "HEAT"
            startTime: "06:00"
            timer: "20:00"
        }
        ListElement {
            name: "Bedroom"
            mode: "COOL"
            startTime: "12:00"
            timer: "30:00"
        }
        ListElement {
            name: "Garage"
            mode: "DRY"
            startTime: "08:00"
            timer: "15:00"
        }
        ListElement {
            name: "Kitchen"
            mode: "COOL"
            startTime: "18:00"
            timer: "25:00"
        }
    }

    Component {
        id: scheduleDelegate
        Rectangle {
            height: 80
            width: parent.width
            color: mouseArea.containsMouse ? "#252525" : "#1a1a1a"
            border.color: "#333"

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            RowLayout {
                id: itemLayout
                spacing: 15
                anchors.fill: parent
                anchors.margins: 15

                property var currentSettings: Config.StyleConfig.modeSettings[model.mode] || Config.StyleConfig.modeSettings["HEAT"]

                // Mode Indicator
                Rectangle {
                    Layout.preferredWidth: 6
                    Layout.fillHeight: true
                    color: itemLayout.currentSettings.color
                    radius: 3
                }

                Rectangle {
                    Layout.preferredHeight: 25
                    Layout.preferredWidth: 25
                    Layout.alignment: Qt.AlignVCenter
                    color: "transparent"

                    Image {
                        id: imgIcon
                        height: 22
                        width: 22
                        source: itemLayout.currentSettings.icon
                        anchors.centerIn: parent
                    }

                    ColorOverlay {
                        source: imgIcon
                        anchors.fill: imgIcon
                        color: itemLayout.currentSettings.color
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: model.name
                        color: "white"
                        font {
                            pixelSize: 16
                            weight: Font.DemiBold
                        }
                    }

                    RowLayout {
                        spacing: 15

                        // Start Time Group
                        Column {
                            Text {
                                text: qsTr("START")
                                color: "#555"
                                font {
                                    pixelSize: 9
                                    bold: true
                                }
                            }

                            Text {
                                text: model.startTime
                                color: "#bbb"
                                font.pixelSize: 14
                            }
                        }

                        // Divider
                        Rectangle {
                            width: 1
                            height: 15
                            color: "#333"
                        }

                        // Duration Group
                        Column {
                            Text {
                                text: "DURATION"
                                color: "#555"
                                font {
                                    pixelSize: 9
                                    bold: true
                                }
                            }

                            Text {
                                text: model.timer + " min"
                                color: "#bbb"
                                font.pixelSize: 14
                            }
                        }
                    }
                }

                Switch {
                    scale: 0.7
                    checked: true
                    Layout.alignment: Qt.AlignVCenter
                    // OnClicked: model.enabled = checked
                }

                Rectangle {
                    //z: 20
                    color: "transparent"
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 32
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.rightMargin: 5
                    opacity: editMouseArea.pressed ? 0.7 : 1.0

                    Image {
                        id: imgEdit
                        source: "../../images/edit.svg"
                        sourceSize: Qt.size(25, 25)
                        anchors.centerIn: parent
                    }

                    ColorOverlay {
                        source: imgEdit
                        anchors.fill: imgEdit
                        color: "#fff"
                    }

                    MouseArea {
                        id: editMouseArea
                        //z: 20
                        anchors.fill: parent
                        onClicked: {
                            console.log("Edit clicked")
                        }
                    }
                }
            }

            MouseArea {
                id: mouseArea
                //anchors.fill: parent
                hoverEnabled: true
                // onClicked: openEditDialog(index) // Opens the edit form
            }
        }
    }
}
