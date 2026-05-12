local vars = require("hyprland.vars")

hl.config({
    input = {
        numlock_by_default = true,
        kb_layout  = vars.is_work_laptop and "us,fr"      or "fr,us",
        kb_variant = vars.is_work_laptop and "intl,azerty" or "azerty,intl",
        kb_model   = "",
        kb_options = "grp:win_space_toggle",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = { natural_scroll = false },
    },
})

hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })
