import QtQuick
import QtQuick.Layouts
import Quickshell

// Drops down under the bar while the pointer is on the top-center of the bar
// (triggerHovered) or on the panel itself.
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

    anchors { top: true }
    margins { top: Theme.barHeight }
    exclusionMode: ExclusionMode.Ignore
    readonly property int pad: 0
    implicitWidth: 900
    implicitHeight: 340
    color: "transparent"
    visible: shown || sheet.y > -sheet.height - pad + 1
    mask: Region { item: sheet }

    Item {
        id: sheet
        x: win.pad
        width: 900
        height: 340
        y: win.shown ? 0 : -height - win.pad
        Behavior on y { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

        HoverHandler { id: hover }

        // brutalist surface: hard 2px outline, sharp corners; extended upward so the
        // top edge hides under the bar and the box hangs from it
        Rectangle {
            y: -40
            width: parent.width
            height: parent.height + 40
            color: Theme.background
            border { width: 2; color: Theme.foreground }
        }

        RowLayout {
            anchors { fill: parent; margins: 18 }
            spacing: 14
            Calendar { Layout.preferredWidth: 320; Layout.fillHeight: true }
            MediaCard { Layout.fillWidth: true; Layout.fillHeight: true }
        }
    }
}
