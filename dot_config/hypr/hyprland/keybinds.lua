local vars = require("hyprland.vars")

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "wofi --show drun --show-icons --allow-images"
local mainMod     = "SUPER"

local function laptop_panel_config()
    if vars.is_work_laptop then
        return { output = "eDP-1", disabled = false, mode = "1920x1200@60", position = "0x0", scale = 1 }
    end

    return { output = "eDP-1", disabled = false, mode = "highres", position = "auto", scale = 1 }
end

local function has_external_monitor()
    for _, monitor in ipairs(hl.get_monitors()) do
        if monitor.name ~= "eDP-1" then
            return true
        end
    end

    return false
end

local function enable_laptop_panel()
    hl.monitor(laptop_panel_config())
    hl.timer(function()
        hl.dispatch(hl.dsp.dpms({ action = "enable", monitor = "eDP-1" }))
        hl.exec_cmd("brightnessctl -r || true")
    end, { timeout = 200, type = "oneshot" })
end

local function disable_laptop_panel()
    if has_external_monitor() then
        hl.monitor({ output = "eDP-1", disabled = true })
    end
end

hl.bind("switch:on:Lid Switch",  disable_laptop_panel, { locked = true })
hl.bind("switch:off:Lid Switch", enable_laptop_panel,  { locked = true })
hl.bind(mainMod .. " + SHIFT + R", enable_laptop_panel, { locked = true })
hl.bind("XF86Display", enable_laptop_panel, { locked = true })

-- Applications
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("close-active"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("wlogout --column-spacing 12 --row-spacing 12"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
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
