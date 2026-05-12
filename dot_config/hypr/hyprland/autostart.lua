hl.on("hyprland.start", function()
    hl.exec_cmd("sh -c 'command -v plasma-apply-colorscheme >/dev/null 2>&1 && plasma-apply-colorscheme BreezeDark'")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("waybar")
    hl.exec_cmd("dunst")
    hl.exec_cmd("hyprpolkitagent")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-copy")
    hl.exec_cmd("clipse -listen")
    -- Disable eDP-1 if lid is already closed at login
    local lid = io.open("/proc/acpi/button/lid/LID0/state")
    if lid then
        local state = lid:read("*l")
        lid:close()
        if state and state:lower():find("closed") then
            hl.monitor({ output = "eDP-1", disabled = true })
        end
    end
end)
