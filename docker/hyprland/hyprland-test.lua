-- Load the deployed configuration, including its normal autostart handlers
-- (Waybar, Clipse, awww, dunst, hypridle, etc.).
dofile(os.getenv("HOME") .. "/.config/hypr/hyprland.lua")

-- run.sh forwards the host XKB configuration. Its fallback is us(intl).
hl.config({
    input = {
        kb_layout  = os.getenv("HYPRLAND_TEST_KB_LAYOUT")  or "us",
        kb_variant = os.getenv("HYPRLAND_TEST_KB_VARIANT") or "intl",
        kb_options = os.getenv("HYPRLAND_TEST_KB_OPTIONS") or "",
    },
})

-- Avoid inheriting the laptop's automatic HiDPI scale in a nested display.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = tonumber(os.getenv("HYPRLAND_TEST_SCALE") or "") or 1,
})

-- A terminal makes an otherwise empty disposable session immediately useful.
-- In browser mode wayvnc 0.10+ serves VNC directly over WebSocket for noVNC.
hl.on("hyprland.start", function()
    hl.exec_cmd("kitty")

    if os.getenv("HYPRLAND_TEST_MODE") == "browser" then
        hl.exec_cmd("wayvnc --render-cursor ws:0.0.0.0:5900")
    end
end)
