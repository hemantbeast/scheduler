import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

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
                    opacity: sideBarId.selectedName === name ? 0.7 : 1.0
                    Layout.alignment: Qt.AlignHCenter

                    Image {
                        id: imageId
                        width: 40
                        height: 40
                        source: sideBarId.selectedName === name ? iconSelected : iconUnselected
                        anchors.centerIn: parent
                    }

                    ColorOverlay {
                        source: imageId
                        anchors.fill: imageId
                        color: sideBarId.selectedName === name ? "#ffffff" : "#e0e0e1"

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }

                    MouseArea {
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
