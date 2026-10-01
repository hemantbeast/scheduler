import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../config"

Item {
    id: commonDialogId
    anchors.centerIn: parent

    property bool isShown: false
    property string headerText: ""
    property int fadeDuration: 300

    // Maps any inline item directly to the visual center container
    default property alias itemLayout: layoutContainer.data

    signal aboutToShow
    signal aboutToHide
    signal accepted
    signal rejected

    function open() {
        dialogId.open()
    }

    function close() {
        commonDialogId.isShown = false
    }

    onIsShownChanged: {
        visualTransitionAnim.stop() // Interrupt any conflicting active movements

        if (isShown) {
            // Setup target entry values
            contentItemId.opacity = 0.0
            contentItemId.scale = 0.3
            visualTransitionAnim.to = 1.0
        } else {
            // Setup target exit values
            visualTransitionAnim.to = 0.0
        }

        visualTransitionAnim.start()
    }

    NumberAnimation {
        id: visualTransitionAnim
        target: contentItemId
        properties: "opacity,scale"
        duration: commonDialogId.fadeDuration
        easing.type: Easing.OutQuad

        // Automatically executes the closing callback when the fade out completes
        onRunningChanged: {
            if (!running && !commonDialogId.isShown) {
                dialogId.close()
            }
        }
    }

    Dialog {
        id: dialogId
        modal: true
        height: parent.height
        width: parent.width
        closePolicy: Popup.NoAutoClose

        onAccepted: commonDialogId.accepted()
        onRejected: commonDialogId.rejected()
        onClosed: commonDialogId.isShown = false

        onAboutToShow: {
            commonDialogId.isShown = true
            commonDialogId.aboutToShow()
        }

        onAboutToHide: {
            commonDialogId.aboutToHide()
        }

        Overlay.modal: Rectangle {
            color: "#D9000000"
        }

        background: Rectangle {
            color: "transparent"
        }

        contentItem: Item {
            id: contentItemId
            anchors.fill: parent

            opacity: commonDialogId.isShown ? 1.0 : 0.0
            scale: commonDialogId.isShown ? 1.0 : 0.3

            Rectangle {
                color: StyleConfig.surface
                border.color: StyleConfig.border
                radius: 5
                anchors.fill: parent
            }

            ColumnLayout {
                spacing: 0
                anchors.fill: parent

                // Header
                Rectangle {
                    color: StyleConfig.surfaceAlt
                    radius: 5
                    Layout.preferredHeight: 50
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop

                    // Prevent bottom corners of header from sticking out of background radius
                    clip: true
                    layer.enabled: true

                    Rectangle {
                        width: parent.width
                        height: parent.radius
                        color: parent.color
                        anchors.bottom: parent.bottom
                    }

                    Label {
                        text: commonDialogId.headerText
                        color: StyleConfig.textPrimary
                        font.bold: true
                        font.pixelSize: 16
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Item layout
                Item {
                    id: layoutContainer
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                // Footer
                Rectangle {
                    color: StyleConfig.surfaceAlt
                    radius: 5
                    clip: true
                    layer.enabled: true

                    Layout.preferredHeight: 60
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom

                    Rectangle {
                        width: parent.width
                        height: parent.radius
                        color: parent.color
                        anchors.top: parent.top
                    }

                    Button {
                        id: okBtn
                        text: qsTr("OK")
                        palette.buttonText: StyleConfig.textPrimary
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        // Custom button background to pop out
                        background: Rectangle {
                            implicitWidth: 80
                            implicitHeight: 36
                            color: okBtn.pressed ? Qt.darker(StyleConfig.accent, 1.2) : StyleConfig.accent
                            radius: 4
                        }
                        onClicked: {
                            commonDialogId.isShown = false
                            commonDialogId.accepted();
                        }
                    }

                    Button {
                        id: cancelBtn
                        text: qsTr("Cancel")
                        palette.buttonText: StyleConfig.accent
                        anchors.right: okBtn.left
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        background: Rectangle {
                            color: "transparent"
                        }
                        onClicked: {
                            commonDialogId.isShown = false
                        }
                    }
                }
            }
        }
    }
}
