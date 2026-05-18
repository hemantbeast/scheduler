import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import QtGraphicalEffects 1.15
import "../../config"
import "../common"

Item {
    id: scheduleRoot

    // Empty schedule list layout
    ColumnLayout {
        id: emptySchedules
        anchors.centerIn: parent
        spacing: 8
        width: parent.width * 0.8
        visible: scheduleModel.rowCount() === 0

        Shape {
            Layout.alignment: Qt.AlignHCenter
            width: 80; height: 80
            layer.enabled: true
            layer.samples: 8

            // Outer Dashed Ring
            ShapePath {
                strokeColor: "#333333"
                strokeWidth: 2
                fillColor: "transparent"
                strokeStyle: ShapePath.DashLine
                dashPattern: [4, 4]
                PathAngleArc { centerX: 40; centerY: 40; radiusX: 35; radiusY: 35; startAngle: 0; sweepAngle: 360 }
            }

            // Inner solid hands icon representation
            ShapePath {
                strokeColor: "#444444"
                strokeWidth: 3
                capStyle: ShapePath.RoundCap
                fillColor: "transparent"
                startX: 40; startY: 20
                PathLine { x: 40; y: 40 }
                PathLine { x: 55; y: 40 }
            }
        }

        // Primary Label Text
        Text {
            text: qsTr("No Schedules Found")
            color: "#eeeeee"
            Layout.topMargin: 8
            Layout.alignment: Qt.AlignHCenter
            font { pixelSize: 18; weight: Font.Medium }
        }

        // Helper Sub-Text Instruction
        Text {
            text: qsTr("Tap the button below to add your first active task configuration window.")
            color: "#666666"
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font { pixelSize: 12; weight: Font.Normal }
        }

        NewScheduleButton {
            Layout.topMargin: 10
            Layout.preferredHeight: 40
            Layout.preferredWidth: 150
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // Schedule list layout
    ColumnLayout {
        id: activeSchedules
        spacing: 0
        anchors.fill: parent
        visible: scheduleModel.rowCount() > 0

        NewScheduleButton {
            Layout.preferredHeight: 40
            Layout.preferredWidth: 150
            Layout.margins: 15
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
        }

        ListView {
            model: scheduleModel
            delegate: scheduleDelegate
            clip: true
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    // List item component
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

                property var currentSettings: StyleConfig.modeSettings[model.mode] || StyleConfig.modeSettings["HEAT"]

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

                    SvgImage {
                        height: 22; width: 22
                        color: itemLayout.currentSettings.color
                        source: itemLayout.currentSettings.icon
                        anchors.centerIn: parent
                    }
                }

                ColumnLayout {
                    spacing: 6
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: model.name
                        color: "white"
                        font {
                            pixelSize: 17
                            weight: Font.Bold
                            letterSpacing: 0.2
                        }
                    }

                    RowLayout {
                        spacing: 15

                        // Start Time Group
                        Row {
                            spacing: 4

                            SvgImage {
                                height: 15; width: 15
                                color: "#777"
                                source: "../../images/play.svg"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: Qt.formatDateTime(model.startTime, "dd MMM yyyy, hh:mm a")
                                color: "#e0e0e0"
                                font {
                                    pixelSize: 13
                                    weight: Font.Medium
                                }
                            }
                        }

                        // Dot Divider
                        Rectangle {
                            width: 4
                            height: 4
                            radius: 2
                            color: "#555"
                            Layout.alignment: Qt.AlignVCenter
                        }

                        // Duration Group
                        Row {
                            spacing: 4

                            SvgImage {
                                height: 15; width: 15
                                color: "#777"
                                source: "../../images/clock.svg"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                color: "#b3b3b3"
                                font {
                                    pixelSize: 13
                                    weight: Font.Medium
                                }
                                text: {
                                    let totalSecs = model.timer;
                                    let mins = Math.floor(totalSecs / 60);
                                    let secs = totalSecs % 60;

                                    mins > 0 ? mins + "m " + secs + "s" : secs + "s";
                                }
                            }
                        }
                    }
                }

                Switch {
                    scale: 0.7
                    checked: model.isEnabled
                    Layout.alignment: Qt.AlignVCenter
                    onCheckedChanged: {
                        scheduleModel.setItemEnabled(index, checked)
                    }
                }

                Row {
                    spacing: 15
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.rightMargin: 5

                    Rectangle {
                        id: rectEdit
                        color: "transparent"
                        height: 32; width: 32
                        enabled: model.isEnabled
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: editMouseArea.pressed ? 0.7 : 1.0

                        SvgImage {
                            id: imgEdit
                            height: 22; width: 22
                            color: "#fff"
                            source: "../../images/edit.svg"
                            anchors.centerIn: parent
                            scale: editMouseArea.pressed ? 0.97 : 1.0

                            Behavior on scale {
                                NumberAnimation { duration: 50 }
                            }
                        }

                        MouseArea {
                            id: editMouseArea
                            anchors.fill: parent
                            onClicked: {
                                stackView.push("AddSchedule.qml", {
                                                   "isEdit": true,
                                                   "index": index,
                                                   "schedule": model
                                               }
                                               )
                            }
                        }
                    }

                    Rectangle {
                        id: rectDelete
                        color: "transparent"
                        height: 32; width: 32
                        enabled: model.isEnabled
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: delMouseArea.pressed ? 0.7 : 1.0

                        SvgImage {
                            id: imgDelete
                            height: 25; width: 25
                            color: "firebrick"
                            source: "../../images/delete.svg"
                            anchors.centerIn: parent
                            scale: delMouseArea.pressed ? 0.97 : 1.0

                            Behavior on scale {
                                NumberAnimation { duration: 50 }
                            }
                        }

                        MouseArea {
                            id: delMouseArea
                            anchors.fill: parent
                            onClicked: {
                                scheduleModel.removeItem(index)
                            }
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
