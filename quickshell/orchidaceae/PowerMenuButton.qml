import QtQuick
import Quickshell

// button: fills with its tone color on hover (no outline)
Rectangle {
    id: btn
    property string glyph
    property string label
    property color tone: Theme.foreground
    property var cmd: []
    implicitWidth: 80
    implicitHeight: 74
    color: ma.containsMouse ? tone : "transparent"
    border.width: 0
    Column {
        anchors.centerIn: parent
        spacing: 6
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: btn.glyph
            color: ma.containsMouse ? Theme.background : btn.tone
            font { family: Theme.iconFont; pixelSize: 22 }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: btn.label
            color: ma.containsMouse ? Theme.background : Theme.foreground
            font { family: Theme.fontFamily; pixelSize: 11; bold: true; capitalization: Font.AllUppercase }
        }
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        onClicked: Quickshell.execDetached(btn.cmd)
    }
}
