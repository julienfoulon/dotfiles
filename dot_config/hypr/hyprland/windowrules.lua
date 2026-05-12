hl.window_rule({ name = "tile-jwlmanager", match = { title         = ".*JWLManager.*"    }, tile = true })
hl.window_rule({ name = "tile-google",     match = { initial_title = ".*Google.*"         }, tile = true })
hl.window_rule({ name = "tile-teams",      match = { initial_title = "^Microsoft Teams$"  }, tile = true })
hl.window_rule({ name = "tile-spotify",    match = { initial_title = "Spotify"            }, tile = true })
hl.window_rule({ name = "tile-pwa",        match = { initial_title = ".*PWA.*"            }, tile = true })

hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

hl.layer_rule({
    name       = "wlogout-blur",
    match      = { namespace = "logout_dialog" },
    blur       = true,
    dim_around = true,
})

hl.window_rule({
    name    = "float-clipse",
    match   = { class = "clipse" },
    float   = true,
    size    = "622 652",
    center  = true,
    opacity = 0.8,
})
