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

    // ---- ANSI colours for kitty: [0-7 normal, 8-15 bright] ----------------
    readonly property var terminal: ({
        kanagawa: {
            dark:  ["#090618","#c34043","#76946a","#c0a36e","#7e9cd8","#957fb8","#6a9589","#c8c093", "#727169","#e82424","#98bb6c","#e6c384","#7fb4ca","#938aa9","#7aa89f","#dcd7ba"],
            alt:   ["#0d0c0c","#c4746e","#8a9a7b","#c4b28a","#8ba4b0","#a292a3","#8ea4a2","#c8c093", "#a6a69c","#e46876","#87a987","#e6c384","#7fb4ca","#938aa9","#7aa89f","#c5c9c5"],
            light: ["#1f1f28","#c84053","#6f894e","#77713f","#4d699b","#b35b79","#597b75","#545464", "#8a8980","#d7474b","#6e915f","#836f4a","#6693bf","#624c83","#5e857a","#43436c"]
        },
        gruvbox: {
            dark:  ["#282828","#cc241d","#98971a","#d79921","#458588","#b16286","#689d6a","#a89984", "#928374","#fb4934","#b8bb26","#fabd2f","#83a598","#d3869b","#8ec07c","#ebdbb2"],
            alt:   ["#1d2021","#cc241d","#98971a","#d79921","#458588","#b16286","#689d6a","#a89984", "#928374","#fb4934","#b8bb26","#fabd2f","#83a598","#d3869b","#8ec07c","#ebdbb2"],
            light: ["#fbf1c7","#cc241d","#98971a","#d79921","#458588","#b16286","#689d6a","#7c6f64", "#928374","#9d0006","#79740e","#b57614","#076678","#8f3f71","#427b58","#3c3836"]
        },
        ayu: {
            dark:  ["#191e2a","#ed8274","#a6cc70","#fad07b","#6dcbfa","#cfbafa","#90e1c6","#c7c7c7", "#686868","#f28779","#bae67e","#ffd580","#73d0ff","#d4bfff","#95e6cb","#ffffff"],
            alt:   ["#01060e","#ea6c73","#91b362","#f9af4f","#53bdfa","#fae994","#90e1c6","#c7c7c7", "#686868","#f07178","#c2d94c","#ffb454","#59c2ff","#ffee99","#95e6cb","#ffffff"],
            light: ["#000000","#ea6c6d","#6cbf43","#eca944","#3199e1","#9e75c7","#46ba94","#bababa", "#686868","#f07171","#86b300","#f2ae49","#399ee6","#a37acc","#4cbf99","#d1d1d1"]
        },
        catppuccin: {
            dark:  ["#45475a","#f38ba8","#a6e3a1","#f9e2af","#89b4fa","#f5c2e7","#94e2d5","#bac2de", "#585b70","#f38ba8","#a6e3a1","#f9e2af","#89b4fa","#f5c2e7","#94e2d5","#a6adc8"],
            alt:   ["#51576d","#e78284","#a6d189","#e5c890","#8caaee","#f4b8e4","#81c8be","#b5bfe2", "#626880","#e78284","#a6d189","#e5c890","#8caaee","#f4b8e4","#81c8be","#a5adce"],
            light: ["#5c5f77","#d20f39","#40a02b","#df8e1d","#1e66f5","#ea76cb","#179299","#acb0be", "#6c6f85","#d20f39","#40a02b","#df8e1d","#1e66f5","#ea76cb","#179299","#bcc0cc"]
        },
        mono: {
            dark:  ["#141414","#c44c4c","#8a8a8a","#a0a0a0","#787878","#909090","#989898","#c8c8c8", "#4a4a4a","#d86060","#9a9a9a","#b8b8b8","#888888","#a8a8a8","#b0b0b0","#e8e8e8"],
            alt:   ["#0c0c0c","#c44c4c","#8a8a8a","#a0a0a0","#787878","#909090","#989898","#c8c8c8", "#4a4a4a","#d86060","#9a9a9a","#b8b8b8","#888888","#a8a8a8","#b0b0b0","#f0f0f0"],
            light: ["#1a1a1a","#b03030","#555555","#666666","#777777","#6a6a6a","#606060","#cccccc", "#888888","#c04040","#666666","#777777","#888888","#7a7a7a","#707070","#f4f4f4"]
        }
    })

    // ---- generated app themes (kitty + GTK3/GTK4) --------------------------
    function mix(a, b, t) {
        const ca = Qt.color(a), cb = Qt.color(b);
        return Qt.rgba(ca.r + (cb.r - ca.r) * t, ca.g + (cb.g - ca.g) * t, ca.b + (cb.b - ca.b) * t, 1).toString();
    }

    function kittyConf(p, t) {
        const L = [
            "# generated by quickshell Theme.qml - do not edit",
            "foreground " + p.foreground, "background " + p.background,
            "selection_foreground " + p.background, "selection_background " + p.accent,
            "cursor " + p.accent, "cursor_text_color " + p.background,
            "url_color " + p.accent,
            "active_border_color " + p.accent, "inactive_border_color " + p.border,
            "bell_border_color " + p.alert,
            "active_tab_foreground " + p.background, "active_tab_background " + p.accent,
            "inactive_tab_foreground " + p.foreground, "inactive_tab_background " + p.border,
            "tab_bar_background " + p.background
        ];
        for (let i = 0; i < 16; i++) L.push("color" + i + " " + t[i]);
        return L.join("\n") + "\n";
    }

    // libadwaita named colours: read by libadwaita (GTK4) and adw-gtk3 (GTK3)
    function gtkCss(p, light) {
        const bg = p.background, fg = p.foreground;
        const m = t => mix(bg, fg, t);
        const shade = light ? "rgba(0, 0, 0, 0.07)" : "rgba(0, 0, 0, 0.36)";
        const d = {
            accent_color: p.accent, accent_bg_color: p.accent, accent_fg_color: bg,
            destructive_color: p.alert, destructive_bg_color: p.alert, destructive_fg_color: bg,
            success_color: p.accent, success_bg_color: p.accent, success_fg_color: bg,
            warning_color: p.secondary, warning_bg_color: p.secondary, warning_fg_color: bg,
            error_color: p.alert, error_bg_color: p.alert, error_fg_color: bg,
            window_bg_color: bg, window_fg_color: fg,
            view_bg_color: light ? mix(bg, "#ffffff", 0.5) : mix(bg, "#000000", 0.15), view_fg_color: fg,
            headerbar_bg_color: m(0.05), headerbar_fg_color: fg,
            headerbar_border_color: p.border, headerbar_backdrop_color: bg, headerbar_shade_color: shade,
            card_bg_color: m(0.06), card_fg_color: fg, card_shade_color: shade,
            dialog_bg_color: bg, dialog_fg_color: fg,
            popover_bg_color: m(0.08), popover_fg_color: fg, popover_shade_color: shade,
            sidebar_bg_color: m(0.03), sidebar_fg_color: fg, sidebar_backdrop_color: bg, sidebar_shade_color: shade,
            secondary_sidebar_bg_color: m(0.05), secondary_sidebar_fg_color: fg,
            secondary_sidebar_backdrop_color: bg, secondary_sidebar_shade_color: shade,
            thumbnail_bg_color: m(0.08), thumbnail_fg_color: fg,
            shade_color: shade, scrollbar_outline_color: p.border
        };
        let out = "/* generated by quickshell Theme.qml - do not edit */\n";
        for (const k in d) out += "@define-color " + k + " " + d[k] + ";\n";
        return out;
    }

    // write kitty + GTK files, make sure they are included, reload what is running
    function syncApps() {
        // read family/variant directly, never `current`/`isLight` (may be stale inside change handlers)
        const p = palettes[family][variant];
        const light = variant === "light";
        const cfg = Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config");
        const script = `
            cfg="$1"
            mkdir -p "$cfg/kitty" "$cfg/gtk-3.0" "$cfg/gtk-4.0"
            printf "%s" "$2" > "$cfg/kitty/quickshell-theme.conf"
            [ -f "$cfg/kitty/kitty.conf" ] || : > "$cfg/kitty/kitty.conf"
            grep -qs quickshell-theme.conf "$cfg/kitty/kitty.conf" || { echo; echo "include quickshell-theme.conf"; } >> "$cfg/kitty/kitty.conf"
            for d in gtk-3.0 gtk-4.0; do
                printf "%s" "$3" > "$cfg/$d/quickshell-colors.css"
                [ -f "$cfg/$d/gtk.css" ] || : > "$cfg/$d/gtk.css"
                grep -qs quickshell-colors "$cfg/$d/gtk.css" || sed -i '1i @import url("quickshell-colors.css");' "$cfg/$d/gtk.css"
            done
            pkill -USR1 -x kitty
            gsettings reset org.gnome.desktop.interface gtk-theme
            gsettings set org.gnome.desktop.interface color-scheme "$4"
            gsettings set org.gnome.desktop.interface gtk-theme "$5"
            true`;
        Quickshell.execDetached(["sh", "-c", script, "sh", cfg,
            kittyConf(p, terminal[family][variant]), gtkCss(p, light),
            light ? "default" : "prefer-dark", light ? "adw-gtk3" : "adw-gtk3-dark"]);
    }
    Timer { id: syncTimer; interval: 150; onTriggered: root.syncApps() }   // coalesce family+variant changes

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
            root.syncApps();   // make kitty/GTK match the saved theme at startup
        }
        onLoadFailed: { root.ready = true; root.syncApps(); }
    }
    onFamilyChanged: { persist(); if (ready) syncTimer.restart(); }
    onVariantChanged: { persist(); if (ready) syncTimer.restart(); }

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
