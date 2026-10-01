import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import QtGraphicalEffects 1.15
import "../../config"
import "../common"
import "../dialogs"

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
                strokeColor: StyleConfig.border
                strokeWidth: 2
                fillColor: "transparent"
                strokeStyle: ShapePath.DashLine
                dashPattern: [4, 4]
                PathAngleArc { centerX: 40; centerY: 40; radiusX: 35; radiusY: 35; startAngle: 0; sweepAngle: 360 }
            }

            // Inner solid hands icon representation
            ShapePath {
                strokeColor: StyleConfig.textDisabled
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
            color: StyleConfig.textPrimary
            Layout.topMargin: 8
            Layout.alignment: Qt.AlignHCenter
            font { pixelSize: 18; weight: Font.Medium }
        }

        // Helper Sub-Text Instruction
        Text {
            text: qsTr("Tap the button below to add your first active task configuration window.")
            color: StyleConfig.textTertiary
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

            property bool isActive: model.id === timerManager.activeScheduleId
            property var currentSettings: StyleConfig.modeSettings[model.mode] || StyleConfig.modeSettings["HEAT"]

            color: isActive ? Qt.darker(currentSettings.color, 8) : (mouseArea.containsMouse ? StyleConfig.surfaceHover : StyleConfig.surface)
            border.color: isActive ? currentSettings.color : StyleConfig.border
            border.width: isActive ? 2 : 1

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Behavior on border.color {
                ColorAnimation { duration: 150 }
            }

            RowLayout {
                id: itemLayout
                spacing: 15
                anchors.fill: parent
                anchors.margins: 15

                // Mode Indicator
                Rectangle {
                    Layout.preferredWidth: 6
                    Layout.fillHeight: true
                    color: currentSettings.color
                    radius: 3
                }

                Rectangle {
                    Layout.preferredHeight: 25
                    Layout.preferredWidth: 25
                    Layout.alignment: Qt.AlignVCenter
                    color: "transparent"

                    SvgImage {
                        height: 24; width: 24
                        color: currentSettings.color
                        source: currentSettings.icon
                        anchors.centerIn: parent
                    }

                    SvgImage {
                        height: 12; width: 12
                        color: StyleConfig.purple
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

                    RowLayout {
                        spacing: 8

                        Text {
                            text: model.name
                            color: model.isEnabled ? StyleConfig.textPrimary : StyleConfig.textSecondary
                            font {
                                pixelSize: 17
                                weight: Font.Bold
                                letterSpacing: 0.2
                            }
                        }

                        Rectangle {
                            visible: isActive
                            width: runningLabel.width + 12
                            height: 18
                            radius: 9
                            color: currentSettings.color

                            Text {
                                id: runningLabel
                                text: qsTr("RUNNING")
                                anchors.centerIn: parent
                                color: StyleConfig.textPrimary
                                font {
                                    pixelSize: 9
                                    bold: true
                                    letterSpacing: 0.5
                                }
                            }

                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                running: isActive
                                NumberAnimation { from: 1.0; to: 0.6; duration: 1000; easing.type: Easing.InOutSine }
                                NumberAnimation { from: 0.6; to: 1.0; duration: 1000; easing.type: Easing.InOutSine }
                            }
                        }
                    }

                    RowLayout {
                        spacing: 15

                        // Start Time Group
                        Row {
                            spacing: 4

                            SvgImage {
                                height: 15; width: 15
                                color: model.isEnabled ? StyleConfig.textTertiary : StyleConfig.textDisabled
                                source: "../../images/play.svg"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: getScheduleDateTimeLabel(model.startTime, model.repeatType, model.repeatDays)
                                color: model.isEnabled ? StyleConfig.textSecondary : StyleConfig.textTertiary
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
                                color: model.isEnabled ? StyleConfig.textTertiary : StyleConfig.textDisabled
                                source: "../../images/clock.svg"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                color: model.isEnabled ? StyleConfig.textSecondary : StyleConfig.textTertiary
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
                                color: switchBtn.checked ? "#80" + StyleConfig.success.toString().substring(1) : StyleConfig.border

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
                                color: switchBtn.checked ? StyleConfig.success : StyleConfig.textPrimary
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
                            color: StyleConfig.textPrimary
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
                            color: StyleConfig.error
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
                                deleteConfirmDialog.scheduleIndex = index
                                deleteConfirmDialog.scheduleName = model.name
                                deleteConfirmDialog.open()
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
            case 0:
                return Qt.formatDateTime(startTime, "d MMM yyyy, hh:mm ap");

            case 1:
                return qsTr("Every day at %1").arg(timeStr);

            case 2:
                if (!repeatDays) return qsTr("Weekly at %1").arg(timeStr);
                const longLabels = [qsTr("Mon"), qsTr("Tue"), qsTr("Wed"), qsTr("Thu"), qsTr("Fri"), qsTr("Sat"), qsTr("Sun")];
                let indices = repeatDays.split(",");
                let days = [];

                indices.forEach(idx => {
                    let n = parseInt(idx.trim());
                    if (n >= 0 && n < 7) days.push(longLabels[n]);
                });

                return qsTr("%1 at %2").arg(days.join(", ")).arg(timeStr);

            case 3:
                let suffix = "th";
                if (dayNum % 10 === 1 && dayNum !== 11) suffix = "st";
                else if (dayNum % 10 === 2 && dayNum !== 12) suffix = "nd";
                else if (dayNum % 10 === 3 && dayNum !== 13) suffix = "rd";

                return qsTr("Every %1%2 of the month at %3").arg(dayNum).arg(suffix).arg(timeStr);

            default:
                return Qt.formatDateTime(startTime, "d MMM yyyy, hh:mm ap");
        }
    }

    ConfirmDialog {
        id: deleteConfirmDialog
        property int scheduleIndex: -1
        property string scheduleName: ""

        message: qsTr("Delete \"%1\"?\nThis action cannot be undone.").arg(scheduleName)
        confirmText: qsTr("Delete")
        confirmColor: StyleConfig.error

        onConfirmed: {
            scheduleModel.removeItem(scheduleIndex)
            toastManager.createMessage(qsTr("Schedule deleted"), {
                type: "success",
                position: Qt.TopEdge,
                theme: "Color"
            })
        }
    }
}
