local vars = require("hyprland.vars")

local chrome           = "/opt/google/chrome/google-chrome --profile-directory=Default"
local work_left_desc   = vars.work_left:gsub("^desc:", "")

local function launch_work_apps()
    local has_outlook, has_teams, has_keepass = false, false, false
    for _, w in ipairs(hl.get_windows()) do
        if w.class:find("faolnafnngnfdaknnbpnkhgohbobgegn") then has_outlook = true end
        if w.class:find("cifhbcnohmdccbgoicgdjpfamggdegmo") then has_teams   = true end
        if w.class == "org.keepassxc.KeePassXC"             then has_keepass = true end
    end
    -- Outlook first so dwindle places it on the left
    if not has_outlook then hl.exec_cmd(chrome .. " --app-id=faolnafnngnfdaknnbpnkhgohbobgegn") end
    if not has_teams   then hl.exec_cmd(chrome .. " --app-id=cifhbcnohmdccbgoicgdjpfamggdegmo") end
    if not has_keepass then hl.exec_cmd("keepassxc")                                             end
end

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
    if vars.is_work_laptop and hl.get_monitor(vars.work_left) then
        launch_work_apps()
    end
end)

if vars.is_work_laptop then
    hl.on("monitor.added", function(monitor)
        if monitor.description == work_left_desc then
            launch_work_apps()
        end
    end)
end
