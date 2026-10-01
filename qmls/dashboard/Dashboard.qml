import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../config"
import "../common"

Item {
    id: dashboardScreen

    readonly property var modeNames: ["auto", "heat", "cool", "dry", "fan"]
    readonly property var modeLabels: ["AUTO", "HEAT", "COOL", "DRY", "FAN"]
    readonly property var modeColors: {
        "heat": StyleConfig.heatColor,
        "cool": StyleConfig.coolColor,
        "dry": StyleConfig.dryColor,
        "fan": StyleConfig.purple,
        "auto": StyleConfig.warning
    }

    function tempText(celsius) {
        return appSettings.convertTemperature(celsius).toFixed(1) + appSettings.unitSymbol
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        anchors.leftMargin: 34
        anchors.topMargin: 50
        spacing: 16

        Text {
            text: qsTr("Dashboard")
            color: StyleConfig.textPrimary
            font { pixelSize: 22; weight: Font.Bold }
        }

        Text {
            text: dashboardBackend.hasData
                  ? qsTr("Live data from shared database")
                  : qsTr("No device data yet - waiting for IDU/ODU")
            color: StyleConfig.textSecondary
            font.pixelSize: 13
        }

        RowLayout {
            spacing: 16
            Layout.fillWidth: true

            // Indoor card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                radius: 12
                color: StyleConfig.surface

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 4

                    Text {
                        text: qsTr("INDOOR")
                        color: StyleConfig.textSecondary
                        font { pixelSize: 12; weight: Font.Medium; letterSpacing: 1 }
                    }
                    Text {
                        text: tempText(dashboardBackend.indoorTemp)
                        color: StyleConfig.textPrimary
                        font { pixelSize: 40; weight: Font.Bold }
                    }
                    Item { Layout.fillHeight: true }
                    Row {
                        spacing: 6
                        SvgImage {
                            source: "../../images/humidity.svg"
                            color: StyleConfig.textSecondary
                            width: 16; height: 16
                        }
                        Text {
                            text: dashboardBackend.humidity.toFixed(0) + "%"
                            color: StyleConfig.textSecondary
                            font.pixelSize: 13
                        }
                    }
                }
            }

            // Outdoor card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                radius: 12
                color: StyleConfig.surface

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 4

                    Text {
                        text: qsTr("OUTDOOR")
                        color: StyleConfig.textSecondary
                        font { pixelSize: 12; weight: Font.Medium; letterSpacing: 1 }
                    }
                    Text {
                        text: tempText(dashboardBackend.outdoorTemp)
                        color: StyleConfig.textPrimary
                        font { pixelSize: 40; weight: Font.Bold }
                    }
                    Item { Layout.fillHeight: true }
                    Text {
                        text: qsTr("ODU")
                        color: StyleConfig.textSecondary
                        font.pixelSize: 13
                    }
                }
            }

            // Target temp card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                radius: 12
                color: StyleConfig.surface

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 4

                    Text {
                        text: qsTr("TARGET")
                        color: StyleConfig.textSecondary
                        font { pixelSize: 12; weight: Font.Medium; letterSpacing: 1 }
                    }

                    RowLayout {
                        spacing: 12

                        Rectangle {
                            width: 34; height: 34
                            radius: 17
                            color: minusArea.pressed ? StyleConfig.surfaceHover : StyleConfig.surfaceAlt
                            Text {
                                anchors.centerIn: parent
                                text: "-"
                                color: StyleConfig.textPrimary
                                font { pixelSize: 20; weight: Font.Bold }
                            }
                            MouseArea {
                                id: minusArea
                                anchors.fill: parent
                                onClicked: dashboardBackend.setTargetTemp(dashboardBackend.targetTemp - 0.5)
                            }
                        }

                        Text {
                            text: tempText(dashboardBackend.targetTemp)
                            color: dashboardScreen.modeColors[dashboardBackend.mode] || StyleConfig.textPrimary
                            font { pixelSize: 28; weight: Font.Bold }
                        }

                        Rectangle {
                            width: 34; height: 34
                            radius: 17
                            color: plusArea.pressed ? StyleConfig.surfaceHover : StyleConfig.surfaceAlt
                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                color: StyleConfig.textPrimary
                                font { pixelSize: 20; weight: Font.Bold }
                            }
                            MouseArea {
                                id: plusArea
                                anchors.fill: parent
                                onClicked: dashboardBackend.setTargetTemp(dashboardBackend.targetTemp + 0.5)
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }

        // Mode + power row
        RowLayout {
            spacing: 10
            Layout.fillWidth: true

            Repeater {
                model: dashboardScreen.modeNames.length

                Rectangle {
                    Layout.preferredHeight: 44
                    Layout.fillWidth: true
                    radius: 10
                    readonly property bool active: dashboardBackend.mode === dashboardScreen.modeNames[index]
                    color: active ? "#33" + String(dashboardScreen.modeColors[dashboardScreen.modeNames[index]]).substring(1) : StyleConfig.surface
                    border.color: active ? dashboardScreen.modeColors[dashboardScreen.modeNames[index]] : "transparent"
                    border.width: 1.5

                    Text {
                        anchors.centerIn: parent
                        text: dashboardScreen.modeLabels[index]
                        color: parent.active ? dashboardScreen.modeColors[dashboardScreen.modeNames[index]] : StyleConfig.textSecondary
                        font { pixelSize: 13; weight: Font.DemiBold; letterSpacing: 1 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: dashboardBackend.setMode(dashboardScreen.modeNames[index])
                    }
                }
            }

            Rectangle {
                Layout.preferredHeight: 44
                Layout.preferredWidth: 90
                radius: 10
                color: dashboardBackend.isOn ? StyleConfig.surface : StyleConfig.surfaceAlt
                border.color: dashboardBackend.isOn ? "transparent" : StyleConfig.heatColor
                border.width: 1.5

                Text {
                    anchors.centerIn: parent
                    text: dashboardBackend.isOn ? qsTr("ON") : qsTr("OFF")
                    color: dashboardBackend.isOn ? StyleConfig.success : StyleConfig.heatColor
                    font { pixelSize: 13; weight: Font.DemiBold; letterSpacing: 1 }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: dashboardBackend.togglePower()
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
