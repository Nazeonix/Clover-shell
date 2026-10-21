import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell

// Neo-brutalist frame: solid border on all sides (thick top = the bar), sharp inner
// corners, 2px hard-outlined boxes, no shadows. The middle is click-through.
Scope {
    id: scope
    required property var modelData

    property bool peek: false
    property bool bandHot: false
    property bool edgeHot: false
    readonly property bool hot: bandHot || edgeHot
    readonly property bool barOpen: !BarCtl.hidden && (!BarCtl.autoHide || peek)
    property real topInset: barOpen ? Theme.barHeight : 0
    Behavior on topInset { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    // left/right/bottom outline follows the bar: gone when the bar is hidden / auto-hidden
    // (visual animates; the layout reserve below only changes when pinned, so peeking never reflows)
    property real frameT: barOpen ? Theme.frameThickness : 0
    Behavior on frameT { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    onHotChanged: {
        if (hot) { hideTimer.stop(); peek = true; }
        else hideTimer.restart();
    }
    Timer { id: hideTimer; interval: 350; onTriggered: scope.peek = false }

    PanelWindow {
        screen: scope.modelData
        anchors { top: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: ((BarCtl.hidden || BarCtl.autoHide) ? 0 : Theme.barHeight) + BarCtl.winbarSpace   // peek overlays, never reflows; + room for WinBar
        mask: Region {}
        implicitWidth: 1
        implicitHeight: 1
    }
    PanelWindow {
        screen: scope.modelData
        anchors { bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: (BarCtl.hidden || BarCtl.autoHide) ? 0 : Theme.frameThickness
        mask: Region {}
        implicitWidth: 1
        implicitHeight: 1
    }
    PanelWindow {
        screen: scope.modelData
        anchors { left: true; top: true; bottom: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: (BarCtl.hidden || BarCtl.autoHide) ? 0 : Theme.frameThickness
        mask: Region {}
        implicitWidth: 1
        implicitHeight: 1
    }
    PanelWindow {
        screen: scope.modelData
        anchors { right: true; top: true; bottom: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: (BarCtl.hidden || BarCtl.autoHide) ? 0 : Theme.frameThickness
        mask: Region {}
        implicitWidth: 1
        implicitHeight: 1
    }

    Dashboard { screen: scope.modelData; triggerHovered: topHover.hovered }
    PowerMenu { screen: scope.modelData; triggerHovered: rightHover.hovered }
    WifiMenu {
        id: wifiMenu
        screen: scope.modelData
        anchorItem: statusIcons.netAnchor
        onUpdated: statusIcons.refreshNet()
    }
    BtMenu {
        id: btMenu
        screen: scope.modelData
        anchorItem: statusIcons.btAnchor
    }

    PanelWindow {
        id: win
        screen: scope.modelData
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        mask: Region {
            x: scope.frameT
            y: scope.topInset
            width: win.width - scope.frameT * 2
            height: win.height - scope.topInset - scope.frameT
            intersection: Intersection.Xor
        }

        Item {
            id: root
            anchors.fill: parent

            readonly property real fl: scope.frameT
            readonly property real ft: scope.topInset
            readonly property real fr: scope.frameT
            readonly property real fb: scope.frameT
            readonly property real r: Theme.frameRadius

            Shape {
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    fillColor: Theme.background
                    strokeWidth: -1
                    fillRule: ShapePath.OddEvenFill

                    startX: 0; startY: 0
                    PathLine { x: root.width; y: 0 }
                    PathLine { x: root.width; y: root.height }
                    PathLine { x: 0; y: root.height }
                    PathLine { x: 0; y: 0 }

                    PathMove { x: root.fl + root.r; y: root.ft }
                    PathLine { x: root.width - root.fr - root.r; y: root.ft }
                    PathArc  { x: root.width - root.fr; y: root.ft + root.r
                               radiusX: root.r; radiusY: root.r; direction: PathArc.Clockwise }
                    PathLine { x: root.width - root.fr; y: root.height - root.fb - root.r }
                    PathArc  { x: root.width - root.fr - root.r; y: root.height - root.fb
                               radiusX: root.r; radiusY: root.r; direction: PathArc.Clockwise }
                    PathLine { x: root.fl + root.r; y: root.height - root.fb }
                    PathArc  { x: root.fl; y: root.height - root.fb - root.r
                               radiusX: root.r; radiusY: root.r; direction: PathArc.Clockwise }
                    PathLine { x: root.fl; y: root.ft + root.r }
                    PathArc  { x: root.fl + root.r; y: root.ft
                               radiusX: root.r; radiusY: root.r; direction: PathArc.Clockwise }
                }
            }

            Item {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                width: scope.frameT + 2
                height: 360
                HoverHandler { id: rightHover }
            }

            Item {
                anchors { left: parent.left; right: parent.right }
                y: scope.topInset - Theme.barHeight
                height: Theme.barHeight
                HoverHandler { onHoveredChanged: scope.bandHot = hovered }

                RowLayout {
                    anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                    spacing: 12
                    Text {
                        text: "\uf303"
                        color: Theme.foreground
                        font { family: Theme.iconFont; pixelSize: 19 }
                        MouseArea {
                            anchors { fill: parent; margins: -6 }
                            onClicked: Launcher.toggle()
                        }
                    }
                    Workspaces {
                        screenName: scope.modelData ? scope.modelData.name : ""
                    }
                }

                Item {
                    anchors.centerIn: parent
                    width: 560
                    height: parent.height
                    HoverHandler { id: topHover }
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 16
                    ActiveWindow {}
                    Clock {}
                }

                RowLayout {
                    anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                    spacing: 16
                    Tray {}
                    StatusIcons {
                        id: statusIcons
                        wifiOpen: wifiMenu.open
                        btOpen: btMenu.open
                        onWifiClicked: { btMenu.open = false; wifiMenu.toggle(); }
                        onBtClicked: { wifiMenu.open = false; btMenu.toggle(); }
                    }
                    Text {
                        text: "\uf013"
                        color: SettingsPanel.open ? Theme.accent : Theme.foreground
                        font { family: Theme.iconFont; pixelSize: 15 }
                        MouseArea {
                            anchors { fill: parent; margins: -4 }
                            onClicked: SettingsPanel.toggle()
                        }
                    }
                }
            }
        }
    }

    PanelWindow {
        screen: scope.modelData
        anchors { top: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        implicitHeight: 3
        color: "transparent"
        visible: BarCtl.autoHide && !BarCtl.hidden && scope.topInset < 8
        HoverHandler { onHoveredChanged: scope.edgeHot = hovered }
    }
}
