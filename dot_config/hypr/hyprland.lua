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
    hl.workspace_rule({ workspace = 4, monitor = "desc:Dell Inc. DELL P2217H 0G2TG68C266T",  persistent = true, default = true })
    hl.workspace_rule({ workspace = 5, monitor = "desc:Dell Inc. DELL P2217H 0G2TG68C266T",  persistent = true })
    hl.workspace_rule({ workspace = 6, monitor = "desc:Dell Inc. DELL P2217H 0G2TG68C266T",  persistent = true })
    hl.workspace_rule({ workspace = 7, monitor = "desc:Dell Inc. DELL UZ2315H 0J4PM66NA36S", persistent = true, default = true })
    hl.workspace_rule({ workspace = 8, monitor = "desc:Dell Inc. DELL UZ2315H 0J4PM66NA36S", persistent = true })
    hl.workspace_rule({ workspace = 9, monitor = "desc:Dell Inc. DELL UZ2315H 0J4PM66NA36S", persistent = true })
else
    hl.workspace_rule({ workspace = 1, monitor = "eDP-1", persistent = true, default = true })
    for i = 2, 5 do
        hl.workspace_rule({ workspace = i, monitor = "eDP-1", persistent = true })
    end
end
