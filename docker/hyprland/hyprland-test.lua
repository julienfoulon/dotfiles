-- Load the deployed configuration, including its normal autostart handlers
-- (Waybar, Clipse, awww, dunst, hypridle, etc.).
dofile(os.getenv("HOME") .. "/.config/hypr/hyprland.lua")

-- A terminal makes an otherwise empty disposable session immediately useful.
-- In browser mode wayvnc 0.10+ serves VNC directly over WebSocket for noVNC.
hl.on("hyprland.start", function()
    hl.exec_cmd("kitty")

    if os.getenv("HYPRLAND_TEST_MODE") == "browser" then
        hl.exec_cmd("wayvnc --render-cursor ws:0.0.0.0:5900")
    end
end)
