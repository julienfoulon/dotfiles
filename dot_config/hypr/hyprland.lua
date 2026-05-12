local vars = require("hyprland.vars")

require("hyprland.monitors")
require("hyprland.autostart")

hl.env("XCURSOR_SIZE",            "24")
hl.env("HYPRCURSOR_SIZE",         "24")
hl.env("PATH",                    os.getenv("HOME") .. "/.local/bin:" .. os.getenv("PATH"))
hl.env("QT_QPA_PLATFORMTHEME",    "kde")
hl.env("QT_QUICK_CONTROLS_STYLE", "org.kde.desktop")

require("hyprland.look_and_feel")
require("hyprland.input")
require("hyprland.keybinds")
require("hyprland.windowrules")

-- Workspace-to-monitor mapping
if vars.is_work_laptop then
    hl.workspace_rule({ workspace = 1, monitor = "eDP-1", default = true })
    hl.workspace_rule({ workspace = 2, monitor = "eDP-1" })
    hl.workspace_rule({ workspace = 3, monitor = "eDP-1" })
    hl.workspace_rule({ workspace = 4, monitor = vars.work_left,  persistent = true, default = true })
    hl.workspace_rule({ workspace = 5, monitor = vars.work_left,  persistent = true })
    hl.workspace_rule({ workspace = 6, monitor = vars.work_left,  persistent = true })
    hl.workspace_rule({ workspace = 7, monitor = vars.work_right, persistent = true, default = true })
    hl.workspace_rule({ workspace = 8, monitor = vars.work_right, persistent = true })
    hl.workspace_rule({ workspace = 9, monitor = vars.work_right, persistent = true })
else
    hl.workspace_rule({ workspace = 1, monitor = "eDP-1", persistent = true, default = true })
    for i = 2, 5 do
        hl.workspace_rule({ workspace = i, monitor = "eDP-1", persistent = true })
    end
end
