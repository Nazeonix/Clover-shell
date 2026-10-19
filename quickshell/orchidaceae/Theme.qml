pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ---- selection -------------------------------------------------------
    property string family: "kanagawa"   // kanagawa | gruvbox | ayu | catppuccin | mono
    property string variant: "dark"      // dark | alt | light
    readonly property var families: ["kanagawa", "gruvbox", "ayu", "catppuccin", "mono"]
    readonly property var variants: ["dark", "alt", "light"]
    readonly property bool isLight: variant === "light"
    property bool ready: false

    readonly property string stateFile:
        (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/quickshell-theme"

    // ---- fonts / metrics -------------------------------------------------
    property string fontFamily: "JetBrainsMono Nerd Font"
    property string iconFont: "JetBrainsMono Nerd Font"
    property int radius: 0
    property int barHeight: 34
    property int frameThickness: 8
    property int frameRadius: 0
    property int clay: 26

    // ---- palettes --------------------------------------------------------
    readonly property var palettes: ({
        kanagawa: {
            dark:  { label: "wave",   background: "#1F1F28", foreground: "#DCD7BA", accent: "#98BB6C", secondary: "#D27E99", alert: "#E82424", border: "#54546D" },
            alt:   { label: "dragon", background: "#181616", foreground: "#C5C9C5", accent: "#87A987", secondary: "#A292A3", alert: "#C4746E", border: "#625E5A" },
            light: { label: "lotus",  background: "#F2ECBC", foreground: "#545464", accent: "#6F894E", secondary: "#B35B79", alert: "#C84053", border: "#C9CBD1" }
        },
        gruvbox: {
            dark:  { label: "medium", background: "#282828", foreground: "#EBDBB2", accent: "#B8BB26", secondary: "#FE8019", alert: "#FB4934", border: "#504945" },
            alt:   { label: "hard",   background: "#1D2021", foreground: "#EBDBB2", accent: "#B8BB26", secondary: "#FE8019", alert: "#FB4934", border: "#3C3836" },
            light: { label: "light",  background: "#FBF1C7", foreground: "#3C3836", accent: "#79740E", secondary: "#AF3A03", alert: "#9D0006", border: "#D5C4A1" }
        },
        ayu: {
            dark:  { label: "mirage", background: "#1F2430", foreground: "#CCCAC2", accent: "#FFCC66", secondary: "#FFA759", alert: "#FF6666", border: "#343F4C" },
            alt:   { label: "dark",   background: "#0B0E14", foreground: "#BFBDB6", accent: "#E6B450", secondary: "#FF8F40", alert: "#F07178", border: "#1B232E" },
            light: { label: "light",  background: "#FCFCFC", foreground: "#5C6166", accent: "#F2A33A", secondary: "#FA8D3E", alert: "#E65050", border: "#D9D8D7" }
        },
        catppuccin: {
            dark:  { label: "mocha",  background: "#1e1e2e", foreground: "#cdd6f4", accent: "#cba6f7", secondary: "#f5c2e7", alert: "#f38ba8", border: "#313244" },
            alt:   { label: "frappe", background: "#303446", foreground: "#c6d0f5", accent: "#ca9ee6", secondary: "#f4b8e4", alert: "#e78284", border: "#414559" },
            light: { label: "latte",  background: "#eff1f5", foreground: "#4c4f69", accent: "#8839ef", secondary: "#ea76cb", alert: "#d20f39", border: "#ccd0da" }
        },
        mono: {
            dark:  { label: "dark",   background: "#141414", foreground: "#e8e8e8", accent: "#a0a0a0", secondary: "#787878", alert: "#c44c4c", border: "#2e2e2e" },
            alt:   { label: "hard",   background: "#0c0c0c", foreground: "#f0f0f0", accent: "#b0b0b0", secondary: "#888888", alert: "#c44c4c", border: "#222222" },
            light: { label: "light",  background: "#f4f4f4", foreground: "#1a1a1a", accent: "#555555", secondary: "#777777", alert: "#b03030", border: "#cccccc" }
        }
    })
    readonly property var current: palettes[family][variant]
    readonly property string variantLabel: current.label

    property color background: current.background
    property color foreground: current.foreground
    property color accent:     current.accent
    property color secondary:  current.secondary
    property color alert:      current.alert
    property color border:     current.border

    Behavior on background { ColorAnimation { duration: 250 } }
    Behavior on foreground { ColorAnimation { duration: 250 } }
    Behavior on accent     { ColorAnimation { duration: 250 } }
    Behavior on secondary  { ColorAnimation { duration: 250 } }
    Behavior on alert      { ColorAnimation { duration: 250 } }
    Behavior on border     { ColorAnimation { duration: 250 } }

    readonly property color barColor: background
    readonly property color pill: Qt.tint(background, Qt.alpha(foreground, 0.14))
    readonly property color surface:  Qt.tint(background, Qt.alpha(foreground, 0.08))
    readonly property color muted:    Qt.alpha(foreground, 0.55)
    readonly property color shadowDark:  Qt.darker(background, isLight ? 1.28 : 2.0)
    readonly property color shadowLight: Qt.lighter(background, isLight ? 1.5 : 1.35)

    function persist() {
        if (!ready) return;
        store.setText(family + " " + variant);
    }
    function syncGtk() {
        // read `variant` directly: isLight can still be stale when this runs from onVariantChanged
        const light = variant === "light";
        const scheme = light ? "default" : "prefer-dark";
        const gtk = light ? "adw-gtk3" : "adw-gtk3-dark";
        Quickshell.execDetached(["gsettings", "set", "org.gnome.desktop.interface", "color-scheme", scheme]);
        Quickshell.execDetached(["gsettings", "set", "org.gnome.desktop.interface", "gtk-theme", gtk]);
    }

    FileView {
        id: store
        path: root.stateFile
        onLoaded: {
            const parts = text().trim().split(/\s+/);
            if (parts.length >= 2
                    && root.families.indexOf(parts[0]) >= 0
                    && root.variants.indexOf(parts[1]) >= 0) {
                root.family = parts[0];
                root.variant = parts[1];
            }
            root.ready = true;
            root.syncGtk();   // make the system match the saved theme at startup
        }
        onLoadFailed: root.ready = true
    }
    onFamilyChanged: persist()
    onVariantChanged: { persist(); if (ready) syncGtk(); }

    function setTheme(f, v) {
        if (families.indexOf(f) < 0 || variants.indexOf(v) < 0) return;
        family = f; variant = v;
    }
    function nextFamily() { family = families[(families.indexOf(family) + 1) % families.length]; }
    function prevFamily() { family = families[(families.indexOf(family) + families.length - 1) % families.length]; }
    function nextVariant() { variant = variants[(variants.indexOf(variant) + 1) % variants.length]; }
    function prevVariant() { variant = variants[(variants.indexOf(variant) + variants.length - 1) % variants.length]; }
    function toggleMode() { variant = isLight ? "dark" : "light"; }

    IpcHandler {
        target: "theme"
        function set(family: string, variant: string): void { root.setTheme(family, variant); }
        function next(): void { root.nextFamily(); }
        function toggle(): void { root.toggleMode(); }
    }
}
