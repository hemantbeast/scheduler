import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "../common" as Common

Item {
    id: sideBarRootId
    width: 70

    signal selected(string name)

    Rectangle {
        id: sideBarId
        anchors.fill: parent
        color: "#252526"

        property string selectedName: "Timer"

        ColumnLayout {
            spacing: 50
            anchors.centerIn: parent

            ListModel {
                id: menuItems
                ListElement {
                    name: "Timer"
                    iconSelected: "../../images/timer_selected.svg"
                    iconUnselected: "../../images/timer_unselected.svg"
                }
                ListElement {
                    name: "Schedule"
                    iconSelected: "../../images/calendar_selected.svg"
                    iconUnselected: "../../images/calendar_unselected.svg"
                }
            }

            Repeater {
                model: menuItems
                Layout.fillWidth: true

                Rectangle {
                    id: itemView
                    width: 50
                    height: 50
                    radius: 8
                    color: "transparent"
                    opacity: itemMouseArea.pressed ? 0.7 : 1.0
                    Layout.alignment: Qt.AlignHCenter

                    Common.SvgImage {
                        id: imageId
                        height:40; width: 40
                        color: sideBarId.selectedName === name ? "#ffffff" : "#e0e0e1"
                        source: sideBarId.selectedName === name ? iconSelected : iconUnselected
                        anchors.centerIn: parent
                        scale: itemMouseArea.pressed ? 0.97 : 1.0

                        Behavior on scale {
                            NumberAnimation { duration: 50 }
                        }
                    }

                    MouseArea {
                        id: itemMouseArea
                        anchors.fill: parent
                        onClicked: {
                            sideBarId.selectedName = name
                            sideBarRootId.selected(name)
                        }
                    }
                }
            }
        }
    }
}
