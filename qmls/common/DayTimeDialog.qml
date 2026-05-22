import QtQuick 2.15
import QtQuick.Controls 2.15

Dialog {
    id: dayTimeDialog

    signal dateTimeSelected(date dateTime)

    property var selectedDate
    property int fadeDuration: 300


    modal: true
    width: 480
    height: 350
    anchors.centerIn: parent

    Overlay.modal: Rectangle {
        color: "#D9000000"
    }

    background: Rectangle {
        color: "#2c3e50"
        border.color: "#34495e"
        radius: 5
        anchors.fill: parent
    }

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: dayTimeDialog.fadeDuration
        }

        NumberAnimation {
            property: "scale"
            from: 0.3
            to: 1.0
            duration: dayTimeDialog.fadeDuration
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: dayTimeDialog.fadeDuration
        }

        NumberAnimation {
            property: "scale"
            from: 1.0
            to: 0.3
            duration: dayTimeDialog.fadeDuration
        }
    }

    onClosed: {
        dayTimeDialog.x = Qt.binding(function() { return 160 })
        dayTimeDialog.y = Qt.binding(function() { return 50 })
    }

    onAboutToShow: {
        let now = selectedDate ?? new Date()

        // Calculate current indexes based on the offset definitions
        let dayIndex    = now.getDate() - 1
        let hourIndex   = now.getHours()
        let minuteIndex = now.getMinutes()

        // 2. Assign indexes directly to the instantiated repeater components
        pickerRepeater.itemAt(0).currentIdx = dayIndex
        pickerRepeater.itemAt(1).currentIdx = hourIndex
        pickerRepeater.itemAt(2).currentIdx = minuteIndex
    }

    onAccepted: {
        let now = new Date()

        // Read index offsets (+1 for days because Tumblers are 0-indexed)
        let day    = pickerRepeater.itemAt(0).currentIdx + 1
        let hour   = pickerRepeater.itemAt(1).currentIdx
        let minute = pickerRepeater.itemAt(2).currentIdx

        // Write formatted string back to the text field
        let dateTime = new Date(now.getFullYear(), now.getMonth(), day, hour, minute, 0)
        dateTimeSelected(dateTime)
    }

    header: Rectangle {
        color: "#1a252f"
        height: 50
        radius: 5

        // Prevent bottom corners of header from sticking out of background radius
        clip: true
        layer.enabled: true

        Rectangle {
            width: parent.width
            height: parent.radius
            color: parent.color
            anchors.bottom: parent.bottom
        }

        Label {
            text: "Choose Day & Time"
            color: "white"
            font.bold: true
            font.pixelSize: 16
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    contentItem: Item {
        anchors.fill: parent

        Row {
            spacing: 15
            anchors.centerIn: parent

            Repeater {
                id: pickerRepeater

                // Unified configuration schema for data generation
                model: [
                    { title: "Day",   size: 31, offset: 1    },
                    { title: "Hour",  size: 24, offset: 0    },
                    { title: "Min",   size: 60, offset: 0    }
                ]

                // The single, reusable Column-Label-Tumbler template
                delegate: Row {
                    id: itemLayout

                    // Store reference to this specific column's configuration data
                    readonly property var config: pickerRepeater.model[index]

                    // Expose the tumbler index directly to the parent scope
                    property alias currentIdx: innerTumbler.currentIndex

                    // Space Layout component
                    Item {
                        height: 1
                        width: 40
                        visible: index === 1
                    }

                    // Item Layout component
                    Column {
                        spacing: 8

                        Label {
                            text: itemLayout.config.title
                            color: "#bdc3c7"
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Tumbler {
                            id: innerTumbler
                            model: itemLayout.config.size
                            visibleItemCount: 5

                            delegate: Label {
                                // Calculate display value using index and configured offset
                                text: String(modelData + itemLayout.config.offset).padStart(2, '0')
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter

                                color: Tumbler.displacement === 0 ? "white" : "#8a8a8a"
                                font.pixelSize: Tumbler.displacement === 0 ? 16 : 14
                                font.bold: Tumbler.displacement === 0

                                Behavior on color { ColorAnimation { duration: 100 } }
                            }

                            background: Item {
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width + 10
                                    height: 30
                                    color: "white"
                                    opacity: 0.12
                                    radius: 4
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    footer: Rectangle {
        color: "#1a252f" // Match header color
        height: 60
        radius: 5
        clip: true
        layer.enabled: true

        Rectangle {
            width: parent.width
            height: parent.radius
            color: parent.color
            anchors.top: parent.top
        }

        Button {
            text: "OK"
            palette.buttonText: "white"
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter

            // Custom button background to pop out
            background: Rectangle {
                implicitWidth: 80
                implicitHeight: 36
                color: parent.pressed ? "#2980b9" : "#3498db"
                radius: 4
            }
            onClicked: dayTimeDialog.accept() // Triggers onAccepted
        }
    }
}
