import QtQuick 2.15
import QtQuick.Controls 2.15

Dialog {
    signal dateTimeSelected(date dateTime)

    // Base year used to offset calculations
    readonly property int baseYear: 2026

    property var selectedDate

    anchors.centerIn: parent
    modal: true
    width: 480
    height: 350

    Overlay.modal: Rectangle {
        color: "#1a1a1a"
        opacity: 0.85
    }

    background: Rectangle {
        color: "#2c3e50"
        border.color: "#34495e"
        radius: 5
        anchors.fill: parent
    }

    onAboutToShow: {
        let now = selectedDate ?? new Date()

        // Calculate current indexes based on the offset definitions
        let yearIndex   = now.getFullYear() - baseYear
        let monthIndex  = now.getMonth() // 0-indexed matches perfectly
        let dayIndex    = now.getDate() - 1
        let hourIndex   = now.getHours()
        let minuteIndex = now.getMinutes()

        // Safely bounds-check the year in case current year falls outside model limits
        if (yearIndex < 0 || yearIndex > 4) {
            yearIndex = 0 // Default to first item if out of bounds
        }

        // 2. Assign indexes directly to the instantiated repeater components
        pickerRepeater.itemAt(0).currentIdx = yearIndex
        pickerRepeater.itemAt(1).currentIdx = monthIndex
        pickerRepeater.itemAt(2).currentIdx = dayIndex
        pickerRepeater.itemAt(3).currentIdx = hourIndex
        pickerRepeater.itemAt(4).currentIdx = minuteIndex
    }

    onAccepted: {
        // Read index offsets (+1 for months/days because Tumblers are 0-indexed)
        let year   = baseYear + pickerRepeater.itemAt(0).currentIdx
        let month  = pickerRepeater.itemAt(1).currentIdx
        let day    = pickerRepeater.itemAt(2).currentIdx + 1
        let hour   = pickerRepeater.itemAt(3).currentIdx
        let minute = pickerRepeater.itemAt(4).currentIdx

        // Write formatted string back to the text field
        let dateTime = new Date(year, month, day, hour, minute, 0)
        dateTimeSelected(dateTime)
    }

    header: Rectangle {
        color: "#1a252f"
        height: 50
        radius: 5

        // Prevent bottom corners of header from sticking out of background radius
        clip: true
        layer.enabled: true

        Label {
            text: "Choose Date & Time"
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
                    { title: "Year",  size: 15,  offset: baseYear },
                    { title: "Month", size: 12, offset: 1    },
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
                        width: 20
                        visible: index === 3
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
            onClicked: dateTimeDialog.accept() // Triggers onAccepted
        }
    }
}
