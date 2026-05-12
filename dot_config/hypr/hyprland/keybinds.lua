local vars = require("hyprland.vars")

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "wofi --show drun --show-icons --allow-images"
local mainMod     = "SUPER"

-- Lid switch (hyprctl keyword is disabled for Lua configs; use eval)
local lid_open_cmd = vars.is_work_laptop
    and [[hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = "0x0", scale = 1 })']]
    or  [[hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "highres", position = "auto", scale = 1 })']]

hl.bind("switch:on:Lid Switch",  hl.dsp.exec_cmd([[hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })']]),  { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd(lid_open_cmd),                                                           { locked = true })

-- Applications
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("close-active"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("wlogout --column-spacing 12 --row-spacing 12"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("pkill wofi || " .. menu))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(terminal .. " --class clipse -e clipse"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("set-wallpaper"))

-- Window management
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Focus
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Workspaces (AZERTY layout keys)
local wsKeys = { "ampersand", "eacute", "quotedbl", "apostrophe", "parenleft", "minus", "egrave", "underscore", "ccedilla", "agrave" }
for i, key in ipairs(wsKeys) do
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Mouse workspace scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Mouse window control
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Audio / media
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("pactl -- set-sink-volume @DEFAULT_SINK@ -10%"))
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("pactl -- set-sink-volume @DEFAULT_SINK@ +10%"))
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("pactl -- set-sink-mute @DEFAULT_SINK@ toggle"))
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("pactl -- set-source-mute 0 toggle"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s +10%"))
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
