pragma Singleton
import QtQuick 2.15

Item {
    id: root

    // Enumerating mode
    readonly property var modeSettings: {
        "HEAT": {
            label: "Heat Mode",
            color: "#FF5F00",
            icon: "../../images/heat.svg",
            bgGradient: "#2a1a10" // Optional: subtle tinted background
        },
        "COOL": {
            label: "Cool Mode",
            color: "#00A3FF",
            icon: "../../images/snowflake.svg",
            bgGradient: "#101a2a"
        },
        "DRY": {
            label: "Dry Mode",
            color: "#00FF94",
            icon: "../../images/humidity.svg",
            bgGradient: "#102a1a"
        }
    }
}
