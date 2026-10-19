import QtQuick
import QtQuick.Layouts
import Quickshell

// Slides in from the right edge: power off, reboot, sleep, hibernate.
PanelWindow {
    id: win
    property bool triggerHovered: false
    property bool shown: false
    readonly property bool wanted: triggerHovered || hover.hovered

    onWantedChanged: {
        if (wanted) { closeTimer.stop(); shown = true; }
        else closeTimer.restart();
    }
    Timer { id: closeTimer; interval: 300; onTriggered: win.shown = false }

    anchors { right: true }                       // vertically centered
    margins { right: Theme.frameThickness }
    exclusionMode: ExclusionMode.Ignore
    readonly property int pad: 0
    implicitWidth: 112
    implicitHeight: 370
    color: "transparent"
    visible: shown || sheet.x < win.implicitWidth - 1
    mask: Region { item: sheet }

    Item {
        id: sheet
        y: win.pad
        width: 112
        height: 370
        x: win.shown ? win.pad : win.implicitWidth
        Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

        HoverHandler { id: hover }

        // brutalist surface: hard 2px outline, sharp corners; extended to the right so
        // the right edge hides under the frame and the box is attached to it
        Rectangle {
            width: parent.width + 40
            height: parent.height
            color: Theme.background
            border { width: 2; color: Theme.foreground }
        }

        ColumnLayout {
            anchors { fill: parent; margins: 14 }
            spacing: 10

            PowerMenuButton {
                glyph: "\uf011"; label: "Power off"; tone: Theme.alert
                cmd: ["systemctl", "poweroff"]
            }
            PowerMenuButton {
                glyph: "\uf021"; label: "Reboot"; tone: Theme.secondary
                cmd: ["systemctl", "reboot"]
            }

            PowerMenuButton {
                glyph: "\uf186"; label: "Sleep"; tone: Theme.accent
                cmd: ["systemctl", "suspend"]
            }
            PowerMenuButton {
                glyph: "\uf2dc"; label: "Hibernate"; tone: Theme.accent
                cmd: ["systemctl", "hibernate"]
            }
        }
    }
}
