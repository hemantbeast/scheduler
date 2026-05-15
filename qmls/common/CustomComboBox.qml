import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ComboBox {
    id: comboField

    contentItem: Text {
        text: comboField.displayText
        font.pixelSize: 14
        color: "white"
        verticalAlignment: Text.AlignVCenter
        leftPadding: 12 // Space text away from left border
        elide: Text.ElideRight
    }

    background: Rectangle {
        color: "#1f1f1f"
        radius: 5
        border {
            width: 1
            // Changes color when dropdown is open or field is focused
            color: (comboField.focus || comboField.popup.visible) ? "white" : "#a1a1a1"
        }
    }

    indicator: Canvas {
        id: canvas
        x: comboField.width - width - 12
        y: (comboField.height - height) / 2
        width: 12
        height: 8
        contextType: "2d"

        onPaint: {
            var ctx = canvas.getContext("2d");
            ctx.reset();
            ctx.moveTo(0, 0);
            ctx.lineTo(width, 0);
            ctx.lineTo(width / 2, height);
            ctx.closePath();
            // Arrow turns white when open, grey when closed
            ctx.fillStyle = comboField.popup.visible ? "white" : "#b0b0b0";
            ctx.fill();
        }

        // Redraw arrow when popup status flips
        Connections {
            target: comboField.popup
            function onVisibleChanged() { canvas.requestPaint(); }
        }
    }

    delegate: ItemDelegate {
        id: itemDel
        width: comboField.width
        height: 36

        contentItem: Text {
            text: modelData
            color: itemDel.highlighted ? "white" : "#b0b0b0"
            font.pixelSize: 14
            verticalAlignment: Text.AlignVCenter
            leftPadding: 12
            elide: Text.ElideRight
        }

        background: Rectangle {
            // Dark highlight color when hovered/selected, solid dark gray otherwise
            color: itemDel.highlighted ? "#2a2a2a" : "#1f1f1f"
        }

        highlighted: comboField.highlightedIndex === index
    }

    popup: Popup {
        y: comboField.height + 4 // Small 4px gap below the field
        width: comboField.width
        implicitHeight: contentItem.implicitHeight
        padding: 2

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: comboField.popup.visible ? comboField.delegateModel : null
            currentIndex: comboField.highlightedIndex

            // Optional: customized scrollbar inside the popup list
            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            color: "#1f1f1f"
            radius: 5
            border.color: "#a1a1a1"
            border.width: 1
        }
    }
}
