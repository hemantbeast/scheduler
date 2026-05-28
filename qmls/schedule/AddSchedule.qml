import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "../common"
import "../dialogs"
import "../toast"

Item {
    id: itemId
    property int index: 0
    property bool isEdit: false

    property var schedule
    property var selectedDateTime
    property var selectedTimer
    onXChanged: {
        console.log("itemId x"+itemId.x)
        console.log("itemId y"+itemId.y)
    }

    ColumnLayout {
        spacing: 4
        anchors.fill: parent

        NavigationHeader {
            id: navigation
            title: isEdit ? "Edit Schedule" : "Add Schedule"
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
        }

        ScrollView {
            id: scrollView
            clip: true
            horizontalPadding: 20
            verticalPadding: 15
            Layout.fillHeight: true
            Layout.fillWidth: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Column {
                id: layout
                spacing: 20
                width: scrollView.availableWidth

                property int currentMode: 0
                property var modeColors: ["#FF5F00", "#00B4FF", "#00FFC2"]
                property var modeNames: ["Heat", "Cool", "Dry"]

                RowLayout {
                    spacing: 15
                    width: parent.width

                    // Name
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0

                        Text {
                            id: txtName
                            text: qsTr("Name")
                            color: "#b0b0b0"
                            font.pointSize: 8
                        }

                        TextField {
                            id: nameField
                            text: isEdit ? schedule.name : ""
                            placeholderText: qsTr("Enter name")
                            placeholderTextColor: "#999"
                            color: "white"
                            clip: true
                            Layout.preferredHeight: 40
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: "#191919"
                                radius: 5

                                border {
                                    width: 1
                                    color: nameField.focus ? "white" : "#424242"
                                }
                            }
                        }
                    }

                    // Mode
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0

                        Text {
                            id: txtMode
                            text: qsTr("Mode")
                            color: "#b0b0b0"
                            font.pointSize: 8
                        }

                        Rectangle {
                            id: segmentedControl
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            Layout.alignment: Qt.AlignHCenter
                            radius: 5
                            color: "#191919"
                            border.color: "#424242"
                            border.width: 1

                            Rectangle {
                                id: activeIndicator
                                width: segmentedControl.width / layout.modeNames.length - 8
                                height: segmentedControl.height - 8
                                radius: 5
                                anchors.verticalCenter: parent.verticalCenter
                                color: layout.modeColors[layout.currentMode]
                                x: 4 + (layout.currentMode * (segmentedControl.width / layout.modeNames.length))

                                Behavior on x {
                                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                                }

                                Behavior on color {
                                    ColorAnimation { duration: 300 }
                                }
                            }

                            Row {
                                anchors.fill: parent

                                Repeater {
                                    model: layout.modeNames

                                    Item {
                                        width: segmentedControl.width / layout.modeNames.length
                                        height: segmentedControl.height

                                        Text {
                                            text: modelData
                                            anchors.centerIn: parent
                                            color: layout.currentMode === index ? "white" : "#8A8A8A"
                                            scale: layout.currentMode === index ? 1.05 : 1.0
                                            font {
                                                pixelSize: 11
                                                letterSpacing: 1.5
                                                bold: true
                                            }

                                            Behavior on color {
                                                ColorAnimation { duration: 250 }
                                            }

                                            Behavior on scale {
                                                NumberAnimation { duration: 200 }
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                layout.currentMode = index
                                            }
                                        }
                                    }
                                }
                            }

                            Component.onCompleted: {
                                if (isEdit) {
                                    let mode = StringHelper.toTitleCase(schedule.mode)
                                    layout.currentMode = layout.modeNames.indexOf(mode)
                                }
                            }
                        }
                    }
                }

                // Repeat
                ColumnLayout {
                    id: repeatLayout
                    spacing: 5
                    width: parent.width

                    property int selectedRepeatType: 0 // 0=Once, 1=Daily, 2=Weekly, 3=Monthly
                    property var selectedDays: [false, false, false, false, false, false, false]
                    property var dayLabels: ["M", "T", "W", "T", "F", "S", "S"]

                    Text {
                        id: txtRepeat
                        text: qsTr("Repeat")
                        color: "#b0b0b0"
                        font.pointSize: 8
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Repeater {
                            model: ["Once", "Daily", "Weekly", "Monthly"]

                            Button {
                                id: repeatTypeBtn
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36

                                // Track button active state
                                property bool isActive: repeatLayout.selectedRepeatType === index

                                contentItem: Text {
                                    text: modelData
                                    color: repeatTypeBtn.isActive ? "#FFFFFF" : "#8A8A8A"
                                    font.bold: repeatTypeBtn.isActive
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    color: repeatTypeBtn.isActive ? "#FF5F00" : "#191919"
                                    border.color: repeatTypeBtn.isActive ? "#FF5F00" : "#424242"
                                    border.width: 1
                                    radius: 6

                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }

                                onClicked: {
                                    selectedDateTime = null
                                    dateField.text = ""
                                    repeatLayout.selectedRepeatType = index
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: weekdayContainer
                        Layout.fillWidth: true
                        Layout.topMargin: 5

                        // Dynamic animation properties based on "Weekly" (index 2) being active
                        Layout.preferredHeight: repeatLayout.selectedRepeatType === 2 ? 50 : 0
                        opacity: repeatLayout.selectedRepeatType === 2 ? 1.0 : 0.0
                        visible: Layout.preferredHeight > 0
                        color: "transparent"
                        clip: true

                        Behavior on Layout.preferredHeight {
                            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                        }

                        Behavior on opacity {
                            NumberAnimation { duration: 200 }
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 12

                            Repeater {
                                model: repeatLayout.dayLabels

                                Rectangle {
                                    id: dayBubble
                                    width: 36
                                    height: 36
                                    radius: width / 2

                                    // Read tracking array states dynamically
                                    property bool isDaySelected: repeatLayout.selectedDays[index]

                                    // Visual states
                                    color: isDaySelected ? "#00B4FF" : "#1B1B1B"
                                    border.color: isDaySelected ? "#00B4FF" : "#2F2F2F"
                                    border.width: 1

                                    Text {
                                        text: modelData
                                        anchors.centerIn: parent
                                        color: dayBubble.isDaySelected ? "#FFFFFF" : "#7A7A7A"
                                        font { pixelSize: 11; bold: true }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            // Toggles the specific boolean slot in our state array
                                            var temp = repeatLayout.selectedDays
                                            temp[index] = !temp[index]
                                            repeatLayout.selectedDays = temp // Triggers binding refresh
                                        }
                                    }

                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                            }
                        }
                    }

                    Component.onCompleted: {
                        if (!isEdit) return

                        repeatLayout.selectedRepeatType = schedule.repeatType

                        if (schedule.repeatType === 2 && schedule.repeatDays) {
                            let days = schedule.repeatDays.split(",")
                            var temp = repeatLayout.selectedDays

                            for (var i = 0; i < days.length; i++) {
                                let index = parseInt(days[i], 10)

                                if (index >= 0 && index < temp.length) {
                                    temp[index] = true
                                }
                            }
                            repeatLayout.selectedDays = temp
                        }
                    }
                }

                RowLayout {
                    spacing: 15
                    width: parent.width

                    // Date and Time
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0

                        Text {
                            id: txtDate
                            text: repeatLayout.selectedRepeatType == 1 || repeatLayout.selectedRepeatType == 2
                                  ? qsTr("Time")
                                  : repeatLayout.selectedRepeatType == 3 ? qsTr("Day & Time") : qsTr("Date & Time")
                            color: "#b0b0b0"
                            font.pointSize: 8
                        }

                        TextField {
                            id: dateField
                            placeholderText: repeatLayout.selectedRepeatType == 1  || repeatLayout.selectedRepeatType == 2
                                             ? qsTr("Select time")
                                             : repeatLayout.selectedRepeatType == 3 ? qsTr("Select day and time") : qsTr("Select date and time")
                            placeholderTextColor: "#999"
                            color: "white"
                            clip: true
                            readOnly: true
                            Layout.preferredHeight: 40
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: "#191919"
                                radius: 5

                                border {
                                    width: 1
                                    color: dateField.focus ? "white" : "#424242"
                                }
                            }

                            Component.onCompleted: {
                                if (isEdit) {
                                    selectedDateTime = schedule.startTime

                                    if (repeatLayout.selectedRepeatType == 3) {
                                        text = "Every " + Qt.formatDateTime(dateTime, "dd") + ", at " + Qt.formatDateTime(dateTime, "hh:mm ap")
                                        return
                                    }

                                    let format = repeatLayout.selectedRepeatType == 1  || repeatLayout.selectedRepeatType == 2
                                        ? "hh:mm ap"
                                        : "dd MMM yyyy, hh:mm ap"
                                    text = Qt.formatDateTime(schedule.startTime, format)
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked:  {
                                    switch (repeatLayout.selectedRepeatType) {
                                    case 1:
                                    case 2:
                                        timeDialog.open()
                                        break
                                    case 3:
                                        dayTimeDialog.open()
                                        break
                                    default:
                                        dateTimeDialog.open()
                                    }
                                }
                            }
                        }

                        Item {
                            height: 28
                            width: 10
                            Layout.topMargin: 5
                        }
                    }

                    // Timer
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0

                        Text {
                            id: txtTimer
                            text: qsTr("Timer")
                            color: "#b0b0b0"
                            font.pointSize: 8
                        }

                        TextField {
                            id: timerField
                            placeholderText: qsTr("Select timer")
                            placeholderTextColor: "#999"
                            color: "white"
                            clip: true
                            readOnly: true
                            Layout.preferredHeight: 40
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: "#191919"
                                radius: 5

                                border {
                                    width: 1
                                    color: timerField.focus ? "white" : "#424242"
                                }
                            }

                            Component.onCompleted: {
                                if (isEdit) {
                                    text = setTimer(schedule.timer)
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: timerDialog.open()
                            }
                        }

                        Row {
                            spacing: 8
                            Layout.topMargin: 5

                            Repeater {
                                model: [
                                    { label: "5m",  secs: 300 },
                                    { label: "10m", secs: 600 },
                                    { label: "15m", secs: 900 },
                                    { label: "30m", secs: 1800 },
                                    { label: "1h",  secs: 3599 }
                                ]

                                delegate: Rectangle {
                                    width: 50
                                    height: 28
                                    radius: 14
                                    color: selectedTimer === modelData.secs ? layout.modeColors[layout.currentMode] : "#191919"
                                    border.color: selectedTimer === modelData.secs ? layout.modeColors[layout.currentMode] : "#424242"
                                    border.width: 1

                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    Behavior on border.color { ColorAnimation { duration: 150 } }

                                    Text {
                                        text: modelData.label
                                        anchors.centerIn: parent
                                        color: selectedTimer === modelData.secs ? "white" : "#8A8A8A"
                                        font {
                                            pixelSize: 11
                                            bold: selectedTimer === modelData.secs
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            selectedTimer = modelData.secs
                                            timerField.text = setTimer(modelData.secs)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            spacing: 15
            Layout.preferredHeight: 70
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20

            Text {
                id: previewLabel
                visible: selectedDateTime && selectedTimer
                text: {
                    if (!selectedDateTime || !selectedTimer) return ""

                    var dayIndices = []
                    if (repeatLayout.selectedRepeatType === 2) {
                        for (var i = 0; i < repeatLayout.selectedDays.length; i++) {
                            if (repeatLayout.selectedDays[i]) {
                                dayIndices.push(i)
                            }
                        }
                    }

                    var repeatDaysString = dayIndices.join(",")
                    var modeName = layout.modeNames[layout.currentMode].toUpperCase()

                    return "Next run: " + timerManager.previewNextOccurrence(
                        modeName,
                        selectedDateTime,
                        selectedTimer,
                        repeatLayout.selectedRepeatType,
                        repeatDaysString
                    )
                }
                color: "#888"
                font {
                    pixelSize: 12
                    italic: true
                }
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            Button {
                id: saveBtn
                height: 40
                Layout.preferredHeight: 40
                Layout.fillWidth: true
                Layout.preferredWidth: 0
                text: isEdit ? "Update" : "Save"
                palette.buttonText: "white"

                onClicked: onAddEditSchedule()

                font {
                    pixelSize: 16
                    weight: Font.Medium
                }

                background: Rectangle {
                    color: "green"
                    radius: 5
                    anchors.fill: parent
                    opacity: saveBtn.pressed ? 0.7 : 1.0
                    scale: saveBtn.pressed ? 0.97 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 50 }
                    }
                }
            }

            Button {
                id: cancelBtn
                height: 40
                Layout.preferredHeight: 40
                Layout.fillWidth: true
                Layout.preferredWidth: 0
                text: "Cancel"
                palette.buttonText: "white"

                onClicked: stackView.pop()

                font {
                    pixelSize: 16
                    weight: Font.Medium
                }

                background: Rectangle {
                    color: "slategray"
                    radius: 5
                    anchors.fill: parent
                    opacity: cancelBtn.pressed ? 0.7 : 1.0
                    scale: cancelBtn.pressed ? 0.97 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 50 }
                    }
                }
            }
        }
    }

    DateTimeDialog {
        id: dateTimeDialog
        selectedDate: selectedDateTime
        onDateTimeSelected: {
            selectedDateTime = dateTime
            dateField.text = Qt.formatDateTime(dateTime, "dd MMM yyyy, hh:mm ap")
        }
    }

    TimerDialog {
        id: timerDialog
        selectedTotalSecs: selectedTimer ?? 0
        onTimeSelected: {
            timerField.text = setTimer(totalSeconds)
        }
    }

    TimeDialog {
        id: timeDialog
        selectedTime: selectedDateTime
        onTimeSelected: {
            selectedDateTime = time
            dateField.text = Qt.formatDateTime(time, "hh:mm ap")
        }
    }

    DayTimeDialog {
        id: dayTimeDialog
        selectedDate: selectedDateTime

        onDateTimeSelected: {
            selectedDateTime = dateTime
            dateField.text = "Every " + Qt.formatDateTime(dateTime, "dd") + ", at " + Qt.formatDateTime(dateTime, "hh:mm ap")
        }
    }

    // Set timer value
    function setTimer(totalSeconds) {
        selectedTimer = totalSeconds

        let minutes = Math.floor((totalSeconds % 3600) / 60)
        let seconds = totalSeconds % 60

        let formattedMinutes = String(minutes).padStart(2, '0')
        let formattedSeconds = String(seconds).padStart(2, '0')

        return `${formattedMinutes}:${formattedSeconds}`
    }

    // On add/edit the schedule
    function onAddEditSchedule() {
        const options = {
            type: "error",
            position: Qt.TopEdge,
            theme: "Color"
        };

        if (nameField.text === "") {
            toastManager.createMessage("Please enter name", options);
            return;
        }

        if (dateField.text === "") {
            toastManager.createMessage("Please select date and time", options);
            return;
        }

        if (timerField.text === "") {
            toastManager.createMessage("Please select timer", options);
            return;
        }

        // Repeat occurence with days
        var dayIndices = [];
        if (repeatLayout.selectedRepeatType === 2) { // Only calculate if 'Weekly' is active
            for (var i = 0; i < repeatLayout.selectedDays.length; i++) {
                if (repeatLayout.selectedDays[i]) {
                    dayIndices.push(i);
                }
            }
        }

        var repeatDaysString = dayIndices.join(",");
        if (repeatLayout.selectedRepeatType === 2 && repeatDaysString === "") {
            toastManager.createMessage("Please select a week day.", options);
            return;
        }

        if (isEdit) {
            scheduleModel.editItem(
                index,
                nameField.text,
                layout.modeNames[layout.currentMode].toUpperCase(),
                selectedDateTime,
                selectedTimer,
                repeatLayout.selectedRepeatType,
                repeatDaysString
            );
        } else {
            if (scheduleModel.nameExists(nameField.text)) {
                toastManager.createMessage("A schedule with this name already exists.", options);
                return;
            }

            scheduleModel.addItem(
                nameField.text,
                layout.modeNames[layout.currentMode].toUpperCase(),
                selectedDateTime,
                selectedTimer,
                repeatLayout.selectedRepeatType,
                repeatDaysString
            );
        }

        stackView.pop();
    }
}
