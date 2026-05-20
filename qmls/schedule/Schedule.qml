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
        visible: scheduleList.count === 0

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
        visible: scheduleList.count > 0

        NewScheduleButton {
            Layout.preferredHeight: 40
            Layout.preferredWidth: 150
            Layout.margins: 15
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
        }

        ListView {
            id: scheduleList
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
            width: ListView.view ? ListView.view.width : 0
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

                    SvgImage {
                        height: 12; width: 12
                        color: "#4CAF50"
                        source: "../../images/repeat.svg"
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: -5
                        anchors.bottomMargin: -5
                        visible: model.repeatType > 0
                    }
                }

                ColumnLayout {
                    spacing: 6
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: model.name
                        color: model.isEnabled ? "white" : "#d9d9d9"
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
                                color: model.isEnabled ? "#777" : "#555"
                                source: "../../images/play.svg"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: getScheduleDateTimeLabel(model.startTime, model.repeatType, model.repeatDays)
                                color: model.isEnabled ? "#e0e0e0" : "#d1d1d1"
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
                                color: model.isEnabled ? "#777" : "#555"
                                source: "../../images/clock.svg"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                color: model.isEnabled ? "#e0e0e0" : "#d1d1d1"
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

                Row {
                    spacing: 20
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.rightMargin: 5

                    Switch {
                        id: switchBtn
                        checked: model.isEnabled
                        onCheckedChanged: {
                            scheduleModel.setItemEnabled(index, checked)
                        }

                        implicitWidth: 40
                        implicitHeight: 20
                        anchors.verticalCenter: parent.verticalCenter

                        indicator: Item {
                            width: parent.width
                            height: parent.height

                            Rectangle {
                                id: trackRect
                                width: parent.width
                                height: 12
                                radius: height / 2
                                anchors.verticalCenter: parent.verticalCenter
                                color: switchBtn.checked ? "#804CAF50" : "#424242"

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }

                            Rectangle {
                                id: thumbCircle
                                width: parent.height
                                height: parent.height
                                radius: width / 2
                                anchors.verticalCenter: parent.verticalCenter
                                color: switchBtn.checked ? "#4CAF50" : "#FFFFFF"
                                x: switchBtn.checked ? (parent.width - width) : 0

                                Behavior on x {
                                    NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: 5; height: 10
                        color: "transparent"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        id: rectEdit
                        color: "transparent"
                        height: 32; width: 32
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
                                })
                            }
                        }
                    }

                    Rectangle {
                        id: rectDelete
                        color: "transparent"
                        height: 32; width: 32
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: delMouseArea.pressed ? 0.7 : 1.0

                        SvgImage {
                            id: imgDelete
                            height: 25; width: 25
                            color: "#EF5350"
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

    function getScheduleDateTimeLabel(startTime, repeatType, repeatDays) {
        let dateObj = new Date(startTime);

        let timeStr = Qt.formatDateTime(startTime, "hh:mm ap");
        let dayNum = Qt.formatDateTime(startTime, "d");

        switch(repeatType) {
            case 0: // Once
                return Qt.formatDateTime(startTime, "d MMM yyyy, hh:mm ap");

            case 1: // Daily
                return "Every day at " + timeStr;

            case 2: // Weekly
                if (!repeatDays) return "Weekly at " + timeStr;
                const longLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                let indices = repeatDays.split(",");
                let days = [];

                indices.forEach(idx => {
                    let n = parseInt(idx.trim());
                    if (n >= 0 && n < 7) days.push(longLabels[n]);
                });

                return days.join(", ") + " at " + timeStr;

            case 3: // Monthly
                let suffix = "th";
                if (dayNum % 10 === 1 && dayNum !== 11) suffix = "st";
                else if (dayNum % 10 === 2 && dayNum !== 12) suffix = "nd";
                else if (dayNum % 10 === 3 && dayNum !== 13) suffix = "rd";

                return "Every " + dayNum + suffix + " of the month at " + timeStr;

            default:
                return Qt.formatDateTime(startTime, "d MMM yyyy, hh:mm ap");
        }
    }
}
