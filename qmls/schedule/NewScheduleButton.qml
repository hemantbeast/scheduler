import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../common"
import "../../config"

Button {
    id: newScheduleBtn
    onClicked: stackView.push("AddSchedule.qml")

    background: Rectangle {
        color: StyleConfig.accent
        radius: 5
        anchors.fill: parent
        opacity: newScheduleBtn.pressed ? 0.7 : 1.0
        scale: newScheduleBtn.pressed ? 0.97 : 1.0

        Behavior on scale {
            NumberAnimation { duration: 50 }
        }
    }

    contentItem: Item {
        Row {
            spacing: 5
            anchors.centerIn: parent

            SvgImage {
                height: 17; width: 17
                color: StyleConfig.textPrimary
                source: "../../images/add.svg"
            }

            Text {
                text: qsTr("New Schedule")
                color: StyleConfig.textPrimary
                font {
                    pixelSize: 15
                    weight: Font.Medium
                }
            }
        }
    }
}
