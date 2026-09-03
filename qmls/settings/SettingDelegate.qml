// SettingDelegate.qml
// Receives all roles from SettingsItemModel and loads the correct control.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ItemDelegate {
    id: root
    width: ListView.view ? ListView.view.width : parent.width
    height: 60

    // ── Roles passed in from the ListView delegate ────────────────────────────
    required property string key
    required property string label
    required property string type
    required property string dataType
    required property var    value
    required property var    defaultValue
    required property real   min
    required property real   max
    required property real   step
    required property string unit
    required property var    options
    required property int    maxLength
    required property string description
    required property bool   isReadOnly

    // ── Emitted up to SettingsScreen ─────────────────────────────────────────
    signal keyValueChanged(string key, var newValue)

    background: Rectangle {
        color: "transparent"
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 1
            color: "#2a2a2a"
        }
    }

    onClicked: {
        switch (root.screenType) {
            case "subcategory":
                itemModel.categoryId = categoryModel.idForKey(root.customScreen)
                stackView.push(settingsItemPage, {
                                   "pageTitle": root.label
                               })
                break

            case "custom":
                stackView.push(customScreenRegistry[root.customScreen])
                break

            case "editor":
            default:
                if (!root.isReadOnly) {
                    editorDialog.open()
                }
                break
        }
    }

    contentItem: Item {
        id: container
        anchors {
            fill: parent
            leftMargin: 24
            rightMargin: 24
        }

        // Label {
        //     text: root.label
        //     font.pixelSize: 26
        //     color: "white"
        //     Layout.fillWidth: true
        // }

        // Label {
        //     text: root.isReadOnly
        //           ? (root.value !== undefined ? root.value.toString() : "-")
        //           : displayValue()
        //     font.pixelSize: 26
        //     color: root.isReadOnly ? "#888888" : "white"
        //     horizontalAlignment: Text.AlignRight
        // }

        Loader {
            id: loader
            width: parent.width
            anchors.centerIn: parent

            // ── Type router ───────────────────────────────────────────────────
            sourceComponent: {
                if (root.isReadOnly) return readonlyComp

                switch (root.type) {
                    case "range":    return sliderComp
                    case "toggle":   return toggleComp
                    case "dropdown": return dropdownComp
                    case "input":    return inputComp
                    default:         return readonlyComp
                }
            }
        }
    }

    // ── Component definitions ─────────────────────────────────────────────────

    Component {
        id: sliderComp
        SliderSetting {
            label:       root.label
            unit:        root.unit
            value:       root.value !== undefined ? root.value : root.min
            minVal:      root.min
            maxVal:      root.max
            stepSize:    root.step
            onCommitted: (newVal) => root.keyValueChanged(root.key, newVal)
        }
    }

    Component {
        id: toggleComp
        ToggleSetting {
            label:       root.label
            checked:     root.value === true || root.value === "1" || root.value === "true"
            onToggled:   (isOn) => root.keyValueChanged(root.key, isOn)
        }
    }

    Component {
        id: dropdownComp
        DropdownSetting {
            label:        root.label
            currentValue: root.value !== undefined ? root.value.toString() : ""
            options:      root.options
            onSelected:   (val) => root.keyValueChanged(root.key, val)
        }
    }

    Component {
        id: inputComp
        InputSetting {
            label:       root.label
            text:        root.value !== undefined ? root.value.toString() : ""
            maxLength:   root.maxLength
            onCommitted: (newText) => root.keyValueChanged(root.key, newText)
        }
    }

    Component {
        id: readonlyComp
        ReadOnlySetting {
            label:        root.label
            displayValue: root.value
        }
    }
}
