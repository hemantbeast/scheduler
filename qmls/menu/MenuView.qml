import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "../common"
import "../../config"

Item {
    id: sideBarRootId
    width: 70

    signal selected(string name)

    Rectangle {
        id: sideBarId
        anchors.fill: parent
        color: StyleConfig.surfaceAlt

        property string selectedName: "Timer"

        ColumnLayout {
            spacing: 30
            anchors.centerIn: parent

            ListModel {
                id: menuItems
                ListElement {
                    name: "Timer"
                    iconSelected: "../../images/timer_selected.svg"
                    iconUnselected: "../../images/timer_unselected.svg"
                }
                ListElement {
                    name: "Dashboard"
                    iconSelected: "../../images/chart.svg"
                    iconUnselected: "../../images/chart.svg"
                }
                ListElement {
                    name: "Schedule"
                    iconSelected: "../../images/calendar_selected.svg"
                    iconUnselected: "../../images/calendar_unselected.svg"
                }
                ListElement {
                    name: "Sleep"
                    iconSelected: "../../images/sleep_selected.svg"
                    iconUnselected: "../../images/sleep_unselected.svg"
                }
                ListElement {
                    name: "Setting"
                    iconSelected: "../../images/setting_selected.svg"
                    iconUnselected: "../../images/setting_unselected.svg"
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

                    SvgImage {
                        id: imageId
                        height:40; width: 40
                        color: sideBarId.selectedName === name ? StyleConfig.textPrimary : StyleConfig.textSecondary
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
