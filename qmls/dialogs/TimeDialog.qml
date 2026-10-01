import QtQuick 2.15
import QtQuick.Controls 2.15

CommonDialog {
    id: timeDialog
    height: 320
    width: 360
    anchors.centerIn: parent
    headerText: "Choose Time"

    property var selectedTime
    signal timeSelected(date time)

    onAboutToShow: {
        let now = selectedTime ?? new Date()

        let hourIndex   = now.getHours()
        let minuteIndex = now.getMinutes()

        pickerRepeater.itemAt(0).currentIdx = hourIndex
        pickerRepeater.itemAt(1).currentIdx = minuteIndex
    }

    onAccepted: {
        let now = selectedTime ?? new Date()

        let hour = pickerRepeater.itemAt(0).currentIdx
        let minute = pickerRepeater.itemAt(1).currentIdx

        let dateTime = new Date(now.getFullYear(), now.getMonth(), now.getDate(), hour, minute, 0)
        timeSelected(dateTime)
    }

    Item {
        anchors.fill: parent

        Row {
            anchors.centerIn: parent
            spacing: 16

            Repeater {
                id: pickerRepeater
                model: [
                    { title: qsTr("Hour"),  size: 24 },
                    { title: qsTr("Min"),   size: 60 }
                ]

                delegate: Column {
                    id: itemLayout
                    spacing: 6

                    readonly property var config: pickerRepeater.model[index]
                    property alias currentIdx: innerTumbler.currentIndex

                    Label {
                        text: itemLayout.config.title
                        color: StyleConfig.textSecondary
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
                            text: String(modelData).padStart(2, '0')
                            font.pixelSize: Tumbler.displacement === 0 ? 16 : 13
                            font.bold: Tumbler.displacement === 0
                            color: Tumbler.displacement === 0 ? StyleConfig.textPrimary : StyleConfig.textTertiary
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
