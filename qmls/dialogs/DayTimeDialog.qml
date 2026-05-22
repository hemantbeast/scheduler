import QtQuick 2.15
import QtQuick.Controls 2.15

CommonDialog {
    id: dayTimeDialog
    width: 480
    height: 350
    headerText: "Choose Day & Time"

    property var selectedDate
    signal dateTimeSelected(date dateTime)

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

    Item {
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
}
