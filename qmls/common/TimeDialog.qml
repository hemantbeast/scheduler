import QtQuick 2.15
import QtQuick.Controls 2.15
import "../../config"

Dialog {
    id: timeDialog
    anchors.centerIn: parent
    modal: true
    width: 360
    height: 320

    signal timeSelected(date time)

    property var selectedTime

    Overlay.modal: Rectangle {
        color: "#1a1a1a"
        opacity: 0.75
    }

    background: Rectangle {
        color: StyleConfig.surface
        border.color: StyleConfig.border
        radius: 5
        anchors.fill: parent
    }

    onAboutToShow: {
        let now = selectedTime ?? new Date()

        let hourIndex   = now.getHours()
        let minuteIndex = now.getMinutes()

        pickerRepeater.itemAt(0).currentIdx = hourIndex
        pickerRepeater.itemAt(1).currentIdx = minuteIndex
    }

    header: Rectangle {
        color: StyleConfig.surfaceAlt
        height: 50
        layer.enabled: true

        Label {
            text: qsTr("Choose Time")
            color: StyleConfig.textPrimary
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

    footer: Rectangle {
        color: StyleConfig.surfaceAlt
        height: 55

        Button {
            text: qsTr("OK")
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            palette.buttonText: StyleConfig.textPrimary

            background: Rectangle {
                implicitWidth: 80
                implicitHeight: 34
                color: parent.pressed ? Qt.darker(StyleConfig.accent, 1.2) : StyleConfig.accent
                radius: 4
            }
            onClicked: {
                let now = selectedTime ?? new Date()

                let hour = pickerRepeater.itemAt(0).currentIdx
                let minute = pickerRepeater.itemAt(1).currentIdx

                let dateTime = new Date(now.getFullYear(), now.getMonth(), now.getDate(), hour, minute, 0)
                timeDialog.timeSelected(dateTime)
                timeDialog.accept()
            }
        }
    }
}
