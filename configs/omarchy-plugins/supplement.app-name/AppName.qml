// Based on Omarchy's built-in Active window widget (omarchy.active-window),
// showing the focused application's name instead of its window title.
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "supplement.app-name"

  readonly property var toplevel: ToplevelManager.activeToplevel
  readonly property string appId: toplevel ? (toplevel.appId || "") : ""
  // Re-evaluated when desktop entries change, so newly installed apps resolve.
  readonly property var entry: {
    var revision = DesktopEntries.applications.values.length
    return appId !== "" ? DesktopEntries.heuristicLookup(appId) : null
  }
  readonly property string title: toplevel ? (toplevel.title || "") : ""
  // Terminal emulators from Omarchy's default/hypr/apps/terminals.lua. Omarchy's
  // own TUI windows (org.omarchy.*, TUI.*) are left out: their app-id already
  // names the program.
  readonly property bool isTerminal: /^(Alacritty|kitty|com\.mitchellh\.ghostty|foot|org\.codeberg\.dnkl\.foot|wezterm)$/.test(appId)

  function capitalize(text) {
    return text ? text.charAt(0).toUpperCase() + text.slice(1) : ""
  }

  // Desktop entry name ("Obsidian", "WhatsApp"); otherwise the last app-id
  // segment, capitalized ("org.omarchy.btop" -> "Btop"). Terminals add the
  // program from their window title, which tmux sets to the running command
  // ("Foot: Claude").
  readonly property string appName: {
    var name = (entry && entry.name) ? entry.name : capitalize(appId.split(".").pop())
    return isTerminal && title !== "" ? name + ": " + capitalize(title) : name
  }
  readonly property int maxLabelWidth: Number(setting("maxWidth", 200))

  visible: appName !== "" && !vertical
  implicitWidth: visible ? Math.min(maxLabelWidth, labelText.implicitWidth) + Style.spacing.controlPaddingX * 2 : 0
  implicitHeight: barSize

  Behavior on implicitWidth {
    NumberAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic }
  }

  Item {
    anchors.fill: parent
    anchors.leftMargin: Style.space(8)
    anchors.rightMargin: Style.space(8)
    clip: true

    Text {
      id: labelText
      textFormat: Text.PlainText
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      width: parent.width
      text: root.appName
      color: root.bar ? root.bar.barForeground : Commons.Color.foreground
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.body
      font.bold: true
      elide: Text.ElideRight
      opacity: 0.85
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor

    onClicked: function(mouse) {
      if (!root.toplevel) return
      if (mouse.button === Qt.MiddleButton) {
        root.toplevel.close()
      } else if (mouse.button === Qt.RightButton) {
        root.toplevel.close()
      } else {
        root.toplevel.activate()
      }
    }
    // Full window title stays available on hover.
    onEntered: if (root.bar) root.bar.showTooltip(root, root.title || root.appName)
    onExited: if (root.bar) root.bar.hideTooltip(root)
  }
}
