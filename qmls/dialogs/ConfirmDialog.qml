import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    anchors.centerIn: parent

    property bool isShown: false
    property string message: "Are you sure?"
    property string confirmText: "Delete"
    property string cancelText: "Cancel"
    property color confirmColor: "#EF5350"
    property int fadeDuration: 300

    signal confirmed()
    signal cancelled()

    function open() {
        dialogId.open()
    }

    function close() {
        root.isShown = false
    }

    onIsShownChanged: {
        visualTransitionAnim.stop()

        if (isShown) {
            contentItemId.opacity = 0.0
            contentItemId.scale = 0.3
            visualTransitionAnim.to = 1.0
        } else {
            visualTransitionAnim.to = 0.0
        }

        visualTransitionAnim.start()
    }

    NumberAnimation {
        id: visualTransitionAnim
        target: contentItemId
        properties: "opacity,scale"
        duration: root.fadeDuration
        easing.type: Easing.OutQuad

        onRunningChanged: {
            if (!running && !root.isShown) {
                dialogId.close()
            }
        }
    }

    Dialog {
        id: dialogId
        modal: true
        height: 250
        width: 400
        anchors.centerIn: parent
        closePolicy: Popup.NoAutoClose

        onClosed: root.isShown = false
        onAboutToShow: root.isShown = true

        Overlay.modal: Rectangle {
            color: "#D9000000"
        }

        background: Rectangle {
            color: "#1a1a1a"
            border.color: "#333"
            radius: 8
        }

        contentItem: Item {
            id: contentItemId

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 30
                width: parent.width * 0.8

                Text {
                    text: root.message
                    color: "white"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 15
                    Layout.alignment: Qt.AlignHCenter

                    Button {
                        id: confirmBtn
                        text: root.confirmText
                        implicitWidth: 120
                        implicitHeight: 40

                        onClicked: {
                            root.isShown = false
                            root.confirmed()
                        }

                        background: Rectangle {
                            color: confirmBtn.pressed ? Qt.darker(root.confirmColor, 1.2) : root.confirmColor
                            radius: 5
                            opacity: confirmBtn.pressed ? 0.8 : 1.0
                            scale: confirmBtn.pressed ? 0.97 : 1.0

                            Behavior on scale {
                                NumberAnimation { duration: 50 }
                            }
                        }

                        contentItem: Text {
                            text: confirmBtn.text
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        id: cancelBtn
                        text: root.cancelText
                        implicitWidth: 120
                        implicitHeight: 40

                        onClicked: {
                            root.isShown = false
                            root.cancelled()
                        }

                        background: Rectangle {
                            color: cancelBtn.pressed ? "#333" : "#2a2a2a"
                            border.color: "#444"
                            border.width: 1
                            radius: 5
                            opacity: cancelBtn.pressed ? 0.8 : 1.0
                            scale: cancelBtn.pressed ? 0.97 : 1.0

                            Behavior on scale {
                                NumberAnimation { duration: 50 }
                            }
                        }

                        contentItem: Text {
                            text: cancelBtn.text
                            color: "#ccc"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }
}
