local vars = require("hyprland.vars")

if vars.is_work_laptop then
    hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = "0x0",  scale = 1 })
else
    hl.monitor({ output = "eDP-1", mode = "highres",      position = "auto", scale = 1 })
end

hl.monitor({ output = "desc:Dell Inc. DELL P2217H 0G2TG68C266T",  mode = "1920x1080@60", position = "1920x0", scale = 1 })
hl.monitor({ output = "desc:Dell Inc. DELL UZ2315H 0J4PM66NA36S", mode = "1920x1080@60", position = "3840x0", scale = 1 })
hl.monitor({ output = "desc:DENON Ltd. DENON-AVRHD 0x01010101",   mode = "highres",      position = "auto",   scale = 2 })
hl.monitor({ output = "",                                          mode = "preferred",    position = "auto",   scale = "auto" })
