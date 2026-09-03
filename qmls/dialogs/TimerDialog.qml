import QtQuick 2.15
import QtQuick.Controls 2.15

CommonDialog {
    id: timerDialog
    width: 360
    height: 320
    anchors.centerIn: parent
    headerText: "Set Timer"

    property int selectedTotalSecs: 0
    signal timeSelected(real totalMs, int totalSeconds)

    onAboutToShow: {
        if (selectedTotalSecs > 0) {
            let minutes = Math.floor((selectedTotalSecs % 3600) / 60)
            let seconds = selectedTotalSecs % 60

            pickerRepeater.itemAt(0).currentIdx = minutes
            pickerRepeater.itemAt(1).currentIdx = seconds
        } else {
            pickerRepeater.itemAt(0).currentIdx = 5  // 5 Minutes
            pickerRepeater.itemAt(1).currentIdx = 0  // 0 Seconds
        }
    }

    onAccepted: {
        let minutes = pickerRepeater.itemAt(0).currentIdx
        let seconds = pickerRepeater.itemAt(1).currentIdx

        // Calculate cumulative durations
        let totalSeconds = (minutes * 60) + seconds
        let totalMs = totalSeconds * 1000

        timeSelected(totalMs, totalSeconds)
    }

    Item {
        anchors.fill: parent

        Row {
            anchors.centerIn: parent
            spacing: 16

            Repeater {
                id: pickerRepeater
                model: [
                    { title: qsTr("Min"),   size: 60 }, // 0 to 59 minutes
                    { title: qsTr("Sec"),   size: 60 }  // 0 to 59 seconds
                ]

                delegate: Column {
                    id: itemLayout
                    spacing: 6

                    readonly property var config: pickerRepeater.model[index]
                    property alias currentIdx: innerTumbler.currentIndex

                    Label {
                        text: itemLayout.config.title
                        color: "#bdc3c7"
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Tumbler {
                        id: innerTumbler
                        model: itemLayout.config.size
                        implicitWidth: 55
                        implicitHeight: 120
                        visibleItemCount: 3

                        delegate: Label {
                            // No offset needed since countdown timers start straight at 00
                            text: String(modelData).padStart(2, '0')
                            font.pixelSize: Tumbler.displacement === 0 ? 16 : 13
                            font.bold: Tumbler.displacement === 0
                            color: Tumbler.displacement === 0 ? "white" : "#7f8c8d"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Item {
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width + 4
                                height: 26
                                color: "white"
                                opacity: 0.1
                                radius: 4
                            }
                        }
                    }
                }
            }
        }
    }
}
