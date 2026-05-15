import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "../common"
import "../toast"

Item {

    property var selectedDateTime
    property var selectedTimer

    ColumnLayout {
        spacing: 4
        anchors.fill: parent

        NavigationHeader {
            id: navigation
            title: "Add Schedule"
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
        }

        ScrollView {
            id: scrollView
            clip: true
            horizontalPadding: 20
            verticalPadding: 15
            Layout.fillHeight: true
            Layout.fillWidth: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Column {
                id: layout
                spacing: 20
                width: scrollView.availableWidth

                RowLayout {
                    spacing: 15
                    width: parent.width

                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0

                        Text {
                            id: txtName
                            text: qsTr("Name")
                            color: "#b0b0b0"
                            font.pointSize: 8
                        }

                        TextField {
                            id: nameField
                            placeholderText: qsTr("Enter name")
                            placeholderTextColor: "#999"
                            color: "white"
                            clip: true
                            Layout.preferredHeight: 40
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: "#1f1f1f"
                                radius: 5

                                border {
                                    width: 1
                                    color: nameField.focus ? "white" : "#a1a1a1"
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0

                        Text {
                            id: txtMode
                            text: qsTr("Mode")
                            color: "#b0b0b0"
                            font.pointSize: 8
                        }

                        CustomComboBox {
                            id: modeField
                            Layout.preferredHeight: 40
                            Layout.fillWidth: true
                            model: ["Heat", "Cool", "Dry"]
                        }
                    }
                }

                RowLayout {
                    spacing: 15
                    width: parent.width

                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0

                        Text {
                            id: txtDate
                            text: qsTr("Date & Time")
                            color: "#b0b0b0"
                            font.pointSize: 8
                        }

                        TextField {
                            id: dateField
                            placeholderText: qsTr("Select date and time")
                            placeholderTextColor: "#999"
                            color: "white"
                            clip: true
                            readOnly: true
                            Layout.preferredHeight: 40
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: "#1f1f1f"
                                radius: 5

                                border {
                                    width: 1
                                    color: dateField.focus ? "white" : "#a1a1a1"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: dateTimeDialog.open()
                            }
                        }
                    }

                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0

                        Text {
                            id: txtTimer
                            text: qsTr("Timer")
                            color: "#b0b0b0"
                            font.pointSize: 8
                        }

                        TextField {
                            id: timerField
                            placeholderText: qsTr("Select timer")
                            placeholderTextColor: "#999"
                            color: "white"
                            clip: true
                            readOnly: true
                            Layout.preferredHeight: 40
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: "#1f1f1f"
                                radius: 5

                                border {
                                    width: 1
                                    color: timerField.focus ? "white" : "#a1a1a1"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: timerDialog.open()
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            spacing: 15
            Layout.preferredHeight: 70
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20

            Button {
                id: saveBtn
                height: 40
                Layout.preferredHeight: 40
                Layout.fillWidth: true
                Layout.preferredWidth: 0
                text: "Save"
                palette.buttonText: "white"

                onClicked: {
                    const options = {
                        type: "error",
                        position: Qt.TopEdge,
                        theme: "Color"
                    };

                    if (nameField.text === "") {
                        toastManager.createMessage("Please enter name", options);
                        return;
                    }

                    if (dateField.text === "") {
                        toastManager.createMessage("Please select date and time", options);
                        return;
                    }

                    if (timerField.text === "") {
                        toastManager.createMessage("Please select timer", options);
                        return;
                    }

                    scheduleModel.addItem(
                                nameField.text,
                                modeField.currentText.toUpperCase(),
                                selectedDateTime,
                                selectedTimer,
                                true
                                );
                    stackView.pop();
                }

                font {
                    pixelSize: 16
                    weight: Font.Medium
                }

                background: Rectangle {
                    color: "green"
                    radius: 5
                    anchors.fill: parent
                    opacity: saveBtn.pressed ? 0.7 : 1.0
                    scale: saveBtn.pressed ? 0.97 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 50 }
                    }
                }
            }

            Button {
                id: cancelBtn
                height: 40
                Layout.preferredHeight: 40
                Layout.fillWidth: true
                Layout.preferredWidth: 0
                text: "Cancel"

                onClicked: stackView.pop()

                font {
                    pixelSize: 16
                    weight: Font.Medium
                }

                background: Rectangle {
                    color: "gray"
                    radius: 5
                    anchors.fill: parent
                    opacity: cancelBtn.pressed ? 0.7 : 1.0
                    scale: cancelBtn.pressed ? 0.97 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 50 }
                    }
                }
            }
        }
    }

    DateTimeDialog {
        id: dateTimeDialog
        onDateTimeSelected: {
            selectedDateTime = dateTime
            dateField.text = Qt.formatDateTime(dateTime, "dd MMM yyyy, hh:mm ap")
        }
    }

    TimerDialog {
        id: timerDialog
        onTimeSelected: {
            selectedTimer = totalSeconds

            let minutes = Math.floor((totalSeconds % 3600) / 60)
            let seconds = totalSeconds % 60

            let formattedMinutes = String(minutes).padStart(2, '0')
            let formattedSeconds = String(seconds).padStart(2, '0')

            timerField.text = `${minutes}:${seconds}`
        }
    }
}
