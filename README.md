# Timer & Scheduler

A desktop application built with Qt 5.15 and QML for creating and managing timed schedules across three climate modes — **Heat**, **Cool**, and **Dry**. Features a real-time animated circular countdown dial, flexible repeat options, and SQLite-backed persistence.

## Features

- **Real-Time Timer Dial** — Animated circular gauge with progress arc, pulsing ring, and live countdown displaying the currently active schedule
- **Three Operating Modes** — Heat (orange), Cool (blue), and Dry (green), each with distinct color theming and icons
- **Schedule Management** — Create, edit, delete, and enable/disable schedules with name uniqueness validation
- **Flexible Repeat Types** — Once, Daily, Weekly (with selectable weekdays), and Monthly recurrence
- **Smart Schedule Processing** — Automatically resolves overlapping schedules (shortest duration wins) and calculates next occurrences for repeating schedules
- **Mode Override** — Manually switch the active mode while a schedule is running
- **Toast Notifications** — Contextual error/success messages for form validation
- **Persistent Storage** — All schedules stored in a local SQLite database (`scheduler.db`)

## Tech Stack

| Layer      | Technology                          |
|------------|-------------------------------------|
| Language   | C++ (Qt 5.15)                       |
| UI         | QML / Qt Quick Controls 2           |
| Database   | SQLite (via `QSqlDatabase`)         |
| Build      | qmake (`.pro`)                      |
| Platform   | Windows (MinGW 32-bit)              |

## Project Structure

```
scheduler/
├── main.cpp                    # Application entry point, context registration
├── scheduler.pro               # qmake project file
├── qml.qrc / resource.qrc      # Qt resource files
├── config/
│   └── StyleConfig.qml         # Singleton for mode colors, icons, and labels
├── src/
│   ├── schedule/
│   │   ├── schedule.h/cpp      # Schedule entity (stub)
│   │   └── schedulemodel.h/cpp # QAbstractListModel for CRUD on schedules
│   └── timer/
│       └── timermanager.h/cpp  # 1-second tick processor, countdown logic
├── utils/
│   ├── databasemanager.h/cpp   # Generic SQLite CRUD wrapper
│   └── stringhelper.h/cpp      # String utility (title case)
├── qmls/
│   ├── main.qml                # Root window with StackView and sidebar nav
│   ├── menu/MenuView.qml       # Icon-based sidebar (Timer / Schedule)
│   ├── timer/TimerNew.qml      # Circular countdown dial with mode selector
│   ├── schedule/
│   │   ├── Schedule.qml        # Schedule list view with toggle/edit/delete
│   │   ├── AddSchedule.qml     # Add/edit form with validation
│   │   └── NewScheduleButton.qml
│   ├── dialogs/                # Custom dialogs (DateTime, Time, DayTime, Timer, Common)
│   ├── toast/                  # Toast notification system
│   └── common/                 # Shared QML components
├── images/                     # SVG icons (modes, actions, navigation)
└── resources/
    ├── fonts/                  # Montserrat font family
    └── icons/                  # Status icons (info, warning, error, success)
```

## Prerequisites

- **Qt 5.15.2** (or compatible version) with the following modules:
  - Qt Quick
  - Qt Quick Controls 2
  - Qt SVG
  - Qt SQL (SQLite driver)
- **MinGW 32-bit** compiler (bundled with Qt installer)
- **Qt Creator** (recommended IDE)

## Building & Running

### Using Qt Creator

1. Open `scheduler.pro` in Qt Creator
2. Select the **Desktop Qt 5.15.2 MinGW 32-bit** kit
3. Click **Run** (Ctrl+R)

### Using the Command Line

```bash
# Generate the Makefile
qmake scheduler.pro

# Build (debug)
mingw32-make -j4 debug

# Run the executable
./build/Desktop_Qt_5_15_2_MinGW_32_bit-Debug/debug/scheduler.exe
```

## Usage

### Timer View

The default view displays an animated circular dial. When a schedule is active:

- The progress arc fills based on remaining time
- The current mode (Heat/Cool/Dry) is shown with color coding
- A **Stop** button appears to halt the active timer
- The **Next Up** label shows the name of the upcoming schedule
- You can manually switch modes using the segmented control at the top

### Schedule View

Switch to the Schedule tab via the sidebar to manage schedules:

1. **Add** — Tap the "+" button, fill in name, mode, date/time, timer duration, and repeat type
2. **Edit** — Tap the edit icon on any schedule row
3. **Delete** — Tap the delete icon to remove a schedule
4. **Enable/Disable** — Toggle the switch to activate or deactivate a schedule without deleting it

### Repeat Types

| Type    | Behavior                                                  |
|---------|-----------------------------------------------------------|
| Once    | Fires at the exact date and time specified                |
| Daily   | Repeats every day at the selected time                    |
| Weekly  | Repeats on selected weekdays (Mon–Sun) at the selected time |
| Monthly | Repeats on the same calendar day each month               |

## Architecture

### Backend (C++)

- **`DatabaseManager`** — Generic SQLite wrapper providing `createTable`, `insertRecord`, `fetchAll`, `updateRecord`, `deleteRecord`, and `addColumnIfNeeded` operations
- **`ScheduleModel`** — Extends `QAbstractListModel` to expose schedule data to QML. Handles CRUD operations and emits `schedulesChanged` when items are toggled
- **`TimerManager`** — Runs a 1-second `QTimer` loop that evaluates all enabled schedules, determines the currently active one (shortest duration wins on overlap), calculates countdown values, and tracks the next upcoming event
- **`StringHelper`** — Utility class exposed to QML for string formatting

### Frontend (QML)

- **Navigation** — `StackView`-based routing with animated page transitions between Timer and Schedule views
- **Timer Dial** — Built with `QtQuick.Shapes` (`PathAngleArc`) for the progress ring, with pulsing animations and tick marks
- **Dialogs** — Custom modal dialogs (`CommonDialog` base) for date/time, time-only, day+time, and timer duration pickers
- **Toast System** — Overlay-based notification system supporting multiple positions (top/bottom, left/center/right) and types (info, warning, error, success)
