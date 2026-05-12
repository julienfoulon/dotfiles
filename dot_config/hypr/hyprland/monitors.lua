local vars = require("hyprland.vars")

if vars.is_work_laptop then
    hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = "0x0",  scale = 1 })
else
    hl.monitor({ output = "eDP-1", mode = "highres",      position = "auto", scale = 1 })
end

hl.monitor({ output = vars.work_left,  mode = "1920x1080@60", position = "1920x0", scale = 1 })
hl.monitor({ output = vars.work_right, mode = "1920x1080@60", position = "3840x0", scale = 1 })
hl.monitor({ output = "desc:DENON Ltd. DENON-AVRHD 0x01010101",   mode = "highres",      position = "auto",   scale = 2 })
hl.monitor({ output = "",                                          mode = "preferred",    position = "auto",   scale = "auto" })
