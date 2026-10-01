pragma Singleton
import QtQuick 2.15

Item {
    id: root

    // ── Centralized Color System ──────────────────────────────────────────────
    // Backgrounds & Surfaces
    readonly property color background:      "#121212"  // App background
    readonly property color surface:        "#1e1e1e"  // Cards, dialogs, popups
    readonly property color surfaceAlt:     "#252526"  // Sidebar, headers
    readonly property color surfaceHover:   "#2a2a2a"  // Hover states
    readonly property color border:         "#333333"  // Borders, dividers

    // Text hierarchy
    readonly property color textPrimary:    "#FFFFFF"  // Headings, key values
    readonly property color textSecondary:  "#B0B0B0"  // Labels, descriptions
    readonly property color textTertiary:   "#808080"  // Placeholders, disabled
    readonly property color textDisabled:   "#555555"  // Disabled states

    // Mode colors (single source of truth)
    readonly property color heatColor:      "#FF5F00"
    readonly property color coolColor:      "#00B4FF"
    readonly property color dryColor:       "#00A884"

    // Semantic colors
    readonly property color accent:         "#2979FF"  // Primary action
    readonly property color success:        "#4CAF50"
    readonly property color warning:        "#FFC107"
    readonly property color error:          "#EF5350"
    readonly property color purple:         "#9D4EDD"

    // Enumerating mode
    readonly property var modeSettings: {
        "HEAT": {
            label: "Heat Mode",
            color: root.heatColor,
            icon: "../../images/heat.svg",
            bgGradient: "#2a1a10" // Optional: subtle tinted background
        },
        "COOL": {
            label: "Cool Mode",
            color: root.coolColor,
            icon: "../../images/snowflake.svg",
            bgGradient: "#101a2a"
        },
        "DRY": {
            label: "Dry Mode",
            color: root.dryColor,
            icon: "../../images/humidity.svg",
            bgGradient: "#102a1a"
        }
    }
}
