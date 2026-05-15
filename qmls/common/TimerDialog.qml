import QtQuick 2.15
import QtQuick.Controls 2.15

Dialog {
    id: timerDialog
    anchors.centerIn: parent
    modal: true
    width: 360
    height: 320

    signal timeSelected(real totalMs, int totalSeconds)

    background: Rectangle {
        color: "#2c3e50"
        border.color: "#34495e"
        radius: 5
        anchors.fill: parent
    }

    onAboutToShow: {
        pickerRepeater.itemAt(0).currentIdx = 5  // 5 Minutes
        pickerRepeater.itemAt(1).currentIdx = 0  // 0 Seconds
    }

    header: Rectangle {
        color: "#1a252f"
        height: 50
        layer.enabled: true

        Label {
            text: "Set Timer"
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
            anchors.centerIn: parent
            spacing: 16

            Repeater {
                id: pickerRepeater
                model: [
                    { title: "Min",   size: 60 }, // 0 to 59 minutes
                    { title: "Sec",   size: 60 }  // 0 to 59 seconds
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

    footer: Rectangle {
        color: "#1a252f"
        height: 55

        Button {
            text: "OK"
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            palette.buttonText: "white"

            background: Rectangle {
                implicitWidth: 80
                implicitHeight: 34
                color: parent.pressed ? "#2980b9" : "#3498db"
                radius: 4
            }
            onClicked: {
                let minutes = pickerRepeater.itemAt(0).currentIdx
                let seconds = pickerRepeater.itemAt(1).currentIdx

                // Calculate cumulative durations
                let totalSeconds = (minutes * 60) + seconds
                let totalMs = totalSeconds * 1000

                timerDialog.timeSelected(totalMs, totalSeconds)
                timerDialog.accept()
            }
        }
    }
}
