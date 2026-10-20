-- Add/remove commands here; each runs once at compositor start.
local cmds = {
    "awww-daemon",
    "qs -c orchidaceae",
    "systemctl --user start hyprpolkitagent",
    "wl-paste --type text --watch cliphist store",
    "wl-paste --type image --watch cliphist store",
}

hl.on("hyprland.start", function()
    for _, cmd in ipairs(cmds) do
        hl.exec_cmd(cmd)
    end
end)
