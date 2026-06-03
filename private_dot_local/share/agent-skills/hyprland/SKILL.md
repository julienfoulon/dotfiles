---
name: hyprland
description: |
  Hyprland window manager configuration using the Lua API (0.55+). Use this skill
  whenever the user asks about Hyprland config — keybinds, window rules, monitors,
  animations, workspace rules, autostart, dispatchers, events, or any hl.* API call.
  Trigger on: "add a keybind", "window rule for X", "configure monitor", "hyprland lua",
  "hl.bind", "hl.config", "why doesn't my hyprland config work", "animate workspaces",
  "make window float", "autostart app", "lid switch", "workspace layout", etc.
  Also trigger when editing any .lua file under ~/.config/hypr/ or chezmoi's
  dot_config/hypr/. Prefer this skill over generic Lua knowledge for all Hyprland work.
  The old hyprlang .conf syntax is deprecated since 0.55 — always write Lua.
---

# Hyprland Lua Config Reference (0.55+)

Hyprland 0.55 replaced hyprlang with Lua. All config is now `.lua`. The `hl` global is
injected by Hyprland — no imports needed. The stubs at `/usr/share/hypr/stubs/hl.meta.lua`
are the authoritative typed API reference; read them when unsure about signatures or fields.

## Linting

`lua-language-server` is available via jvim's Mason install — no extra packages needed:

```bash
~/.local/share/jvim/mason/bin/lua-language-server \
  --check ~/.config/hypr/ \
  --configpath ~/.config/hypr/.luarc.json
```

The `.luarc.json` at `~/.config/hypr/` (tracked in chezmoi as `dot_config/hypr/dot_luarc.json`) wires up the stubs:
```json
{
  "workspace": { "library": ["/usr/share/hypr/stubs"], "checkThirdParty": false },
  "diagnostics": { "globals": ["hl"] }
}
```

**Run this after every edit.** If the checker reports read-only filesystem errors while
creating Mason `meta/` files, rerun it with normal write access; otherwise Lua built-ins
such as `require`, `io`, `os`, `ipairs`, and string methods may show as noisy false
positives. Known stub constraint: `workspace_rule` types `workspace` as `string`, so
always pass string selectors (`"1"` not `1`) to keep the checker clean.

## File structure

Entry point: `~/.config/hypr/hyprland.lua`  
Modules: `require("hyprland.foo")` → `~/.config/hypr/hyprland/foo.lua`

Typical split:
```
hyprland.lua          -- entry: require() modules, hl.env(), workspace rules
hyprland/vars.lua     -- hostname detection, named constants
hyprland/monitors.lua
hyprland/look_and_feel.lua
hyprland/input.lua
hyprland/keybinds.lua
hyprland/windowrules.lua
hyprland/autostart.lua
```

## Critical sandbox restrictions

| Blocked | Use instead |
|---------|-------------|
| `io.popen()` | `io.open("/etc/hostname")` for hostname detection |
| `hyprctl keyword` | `hyprctl eval 'hl.monitor({...})'` for runtime changes |
| `mode = "disabled"` on monitor | `disabled = true` field |
| `Date.now()` / bare `new Date()` | `os.time()` for timestamps/seeds |

`hl.dispatch()` calls inside event handlers or timer callbacks require calling `hl.dispatch(hl.dsp.something())` explicitly — `hl.dsp.*` alone only creates a dispatcher object.

---

## hl.config()

Additive — call multiple times. Keys documented at `general.*`, `decoration.*`, etc. in stubs.

```lua
hl.config({
    general = {
        gaps_in = 5, gaps_out = 20, border_size = 2,
        col = {
            active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false, allow_tearing = false,
        layout = "dwindle",  -- "dwindle" | "master" | "scrolling" | custom
    },
    decoration = {
        rounding = 10, rounding_power = 2,
        active_opacity = 1.0, inactive_opacity = 1.0,
        dim_inactive = true, dim_strength = 0.15,
        shadow = { enabled = true, range = 4, render_power = 3, color = 0xee1a1a1a },
        blur   = { enabled = true, size = 3, passes = 1, vibrancy = 0.1696 },
    },
    animations = { enabled = true },
    misc       = { force_default_wallpaper = -1, disable_hyprland_logo = true },
    dwindle    = { preserve_split = true },
    master     = { new_status = "master", mfact = 0.55 },
    scrolling  = { fullscreen_on_one_column = true },
    input = {
        kb_layout = "us", kb_variant = "", kb_options = "",
        follow_mouse = 1, sensitivity = 0,
        touchpad = { natural_scroll = true },
    },
})
```

---

## hl.monitor()

```lua
hl.monitor({
    output   = "",                    -- name | "desc:Dell Inc. ..." | "" (wildcard/fallback)
    mode     = "1920x1080@60",        -- or "highres" | "preferred"
    position = "0x0",                 -- or "auto"
    scale    = 1,                     -- number or "auto"
    disabled = false,                 -- true to turn off
    transform = 0,                    -- 0-7 (rotation: 1=90°, 2=180°, 3=270°, 4-7 flipped)
    mirror   = "eDP-1",               -- mirror another output
    reserved = { top = 0, right = 0, bottom = 0, left = 0 },
})
```

Runtime toggle (only via `hyprctl eval`, not `hyprctl keyword`):
```lua
-- In a keybind handler or event callback:
hl.monitor({ output = "eDP-1", disabled = true })
-- Or from shell:
-- hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })'
```

---

## hl.bind()

```lua
hl.bind(keys, dispatcher_or_function, opts?)
```

**Key formats:**
```lua
"SUPER + Q"                  -- modifier + key
"SUPER + SHIFT + S"          -- multiple modifiers
"XF86AudioRaiseVolume"       -- media/function key
"mouse:272"                  -- mouse button (272=LMB, 273=RMB, 274=middle)
"mouse_down" / "mouse_up"    -- scroll wheel
"switch:on:Lid Switch"       -- hardware switch (on=closed, off=open)
"code:172"                   -- raw keycode when no symbol name exists
```

**Options:**
```lua
{ locked = true }            -- works on lock screen
{ repeating = true }         -- fires repeatedly while held
{ release = true }           -- triggers on key release
{ mouse = true }             -- mouse button binding
{ ignore_mods = true }       -- ignore modifier state
{ description = "..." }      -- shown in keybind docs
```

**Return value** — handle for runtime control:
```lua
local h = hl.bind(...)
h:set_enabled(false)
h:remove()
```

**Dispatcher vs function:**
```lua
-- Dispatcher: single built-in action
hl.bind("SUPER + Q", hl.dsp.exec_cmd(terminal))

-- Function: multiple actions, conditional logic, layout-aware
hl.bind("SUPER + F", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.center())
end)
```

**Loop pattern for workspaces:**
```lua
for i = 1, 9 do
    hl.bind("SUPER + " .. (i % 10),             hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. (i % 10),     hl.dsp.window.move({ workspace = i, follow = false }))
    hl.bind("SUPER + CTRL + " .. (i % 10),      hl.dsp.window.move({ workspace = i }))
end
```

**Submaps:** `hl.define_submap(name, fn)` — binds inside fn are scoped to the submap; exit with `hl.dsp.submap("reset")`; enter with `hl.bind("SUPER + R", hl.dsp.submap("resize"))`.

---

## Dispatchers (hl.dsp.*)

`hl.dsp.*` returns a dispatcher object. Use directly in `hl.bind()`, or call via `hl.dispatch()` elsewhere.

```lua
-- In bind (implicit dispatch)
hl.bind("SUPER + Q", hl.dsp.window.close())

-- Explicit dispatch (event handlers, timers, functions)
hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
```

**Core:**
```lua
hl.dsp.exec_cmd(cmd, window_rules?)   -- launch; optional rules: {float=true}, {workspace="4"}
hl.dsp.exit()
hl.dsp.dpms({ action = "enable"|"disable", monitor = "eDP-1" })
hl.dsp.submap(name)                   -- "reset" to exit
hl.dsp.layout(msg)                    -- layout-specific message (see layouts section)
```

**Focus:**
```lua
hl.dsp.focus({ direction = "left"|"right"|"up"|"down" })
hl.dsp.focus({ workspace = 3 })           -- by number
hl.dsp.focus({ workspace = "e+1" })       -- relative: e+N / e-N
hl.dsp.focus({ workspace = "special:magic" })
hl.dsp.focus({ workspace = "w[tv1]" })    -- workspaces with tiled+visible, 1 window
hl.dsp.focus({ workspace = "f[1]" })      -- first floating workspace
```

**Window:**
```lua
hl.dsp.window.close() / kill() / center() / pin() / pseudo() / drag()
hl.dsp.window.float({ action = "toggle"|"on"|"off", window? })
hl.dsp.window.fullscreen({ action = "toggle" })
hl.dsp.window.resize({ x = 80, y = 0, relative = true })
hl.dsp.window.move({ workspace = "special:magic", follow = false })
hl.dsp.window.move({ direction = "left", window = "address:0x..." })
hl.dsp.window.swap({ direction = "right" })
hl.dsp.window.tag({ tag = "bordered" })
```
Target a specific window with `window = "address:0x..."` or `window = "class:foo"`.

**Workspace:**
```lua
hl.dsp.workspace.move({ workspace = 3 })
hl.dsp.workspace.toggle_special("magic")
hl.dsp.workspace.rename("new name")
```

**Groups:**
```lua
hl.dsp.group.toggle()
hl.dsp.group.next() / hl.dsp.group.prev()
hl.dsp.group.lock()
```

**Layout messages:**
```lua
-- dwindle
hl.dsp.layout("togglesplit")
hl.dsp.layout("swapsplit")
hl.dsp.layout("movetoroot active")

-- master
hl.dsp.layout("cyclenext") / hl.dsp.layout("cycleprev")
hl.dsp.layout("swapwithmaster")

-- scrolling
hl.dsp.layout("swapcol l") / hl.dsp.layout("swapcol r")
hl.dsp.layout("colresize +conf") / hl.dsp.layout("colresize -conf")
```

---

## Window, layer & workspace rules

```lua
local rule = hl.window_rule({
    name  = "float-dialog",
    -- Match fields (all optional, regex strings):
    match = { class = "thunar", title = ".*Dialog.*", initial_class = "...",
              xwayland = true, float = false, fullscreen = false, pin = false, workspace = "4" },
    -- Effects (any combination):
    workspace = "4 silent",  -- "silent" = don't switch to it
    float = true,  tile = true,  size = "800 600",  center = true,
    move  = "20 monitor_h-120",  opacity = 0.9,  splitratio = 1.5,
    border_size = 2,  rounding = 10,  no_focus = true,  suppress_event = "maximize",
})
rule:set_enabled(false)
```

```lua
-- Layer rule (for waybar, wlogout, dunst, etc.)
hl.layer_rule({
    name      = "wlogout-blur",
    match     = { namespace = "logout_dialog" },
    blur      = true,
    dim_around = true,
    xray      = false,
    no_anim   = false,
    above_lock = false,
    animation = "slide right",
})
```

```lua
-- Workspace rule
hl.workspace_rule({
    workspace  = "4",                         -- string selector; stubs require string
    monitor    = "desc:Dell Inc. DELL P2217H 0G2TG68C266T",
    default    = true,
    persistent = true,
    layout     = "master",
    gaps_in    = 0,
    gaps_out   = 0,
    border_size = 0,
    no_border  = true,
})
```

---

## Events (hl.on)

```lua
hl.on("hyprland.start", function() ... end)
hl.on("hyprland.shutdown", function() ... end)
hl.on("config.reloaded", function() ... end)

hl.on("monitor.added",   function(monitor) ... end)   -- monitor = HL.Monitor
hl.on("monitor.removed", function(monitor) ... end)
hl.on("monitor.focused", function(monitor) ... end)

hl.on("window.open",           function(window) ... end)
hl.on("window.open_early",     function(window) ... end)
hl.on("window.close",          function(window) ... end)
hl.on("window.active",         function(window) ... end)
hl.on("window.title",          function(window) ... end)
hl.on("window.move_to_workspace", function(window) ... end)

hl.on("workspace.active",      function(workspace) ... end)
hl.on("workspace.created",     function(workspace) ... end)
hl.on("workspace.removed",     function(workspace) ... end)

hl.on("screenshare.state", function(state) ... end)
hl.on("keybinds.submap",   function(name)  ... end)
```

Returns a subscription handle with `:remove()` and `:is_active()`.

---

## Animations

```lua
-- Bezier curve
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })

-- Spring curve (new in 0.55)
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

-- Animation leaf
hl.animation({ leaf = "windows",    enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4.1,  spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
```

**All leaves:** `global`, `border`, `windows` / `windowsIn` / `windowsOut`, `fade` / `fadeIn` / `fadeOut`,
`layers` / `layersIn` / `layersOut` / `fadeLayersIn` / `fadeLayersOut`,
`workspaces` / `workspacesIn` / `workspacesOut`, `zoomFactor`

**Styles:** `popin N%`, `slide`, `slide [direction]`, `fade`, `gnome`

---

## Runtime utilities

```lua
hl.exec_cmd(cmd)                                    -- fire-and-forget shell
hl.env("XCURSOR_SIZE", "24")                        -- set env var
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

-- Timer
local t = hl.timer(function() ... end, { timeout = 16, type = "repeat" })
t:set_enabled(false)   -- pause
-- type = "oneshot" fires once after timeout ms
-- type = "repeat"  fires every timeout ms until disabled

-- Notification
hl.notification.create({ text = "hello", timeout = 3000, color = "rgba(ff0000ff)" })
```

---

## Query functions

```lua
hl.get_windows(filters?)          -- HL.Window[]
hl.get_window(selector)           -- HL.Window | nil
hl.get_active_window()            -- HL.Window | nil
hl.get_monitors()                 -- HL.Monitor[]
hl.get_monitor(selector)          -- HL.Monitor | nil  (selector = name or "desc:...")
hl.get_monitor_at({ x=0, y=0 })   -- HL.Monitor | nil
hl.get_active_monitor()           -- HL.Monitor | nil
hl.get_workspaces()               -- HL.Workspace[]
hl.get_workspace(selector)        -- HL.Workspace | nil
hl.get_active_workspace()         -- HL.Workspace | nil
hl.get_active_special_workspace() -- HL.Workspace | nil
hl.get_layers(filters?)           -- layer surfaces
hl.get_cursor_pos()               -- {x, y}
```

**Key fields** (check stubs for full list):
- `HL.Window`: `class`, `initial_class`, `title`, `address`, `at.x/y`, `size`, `floating`, `fullscreen`, `workspace`, `monitor`, `pid`, `xwayland`, `tags`
- `HL.Workspace`: `id`, `name`, `tiled_layout`, `monitor`, `active`, `is_empty`, `windows`
- `HL.Monitor`: `name`, `description`, `x`, `y`, `width`, `height`, `scale`, `refresh_rate`, `focused`

---

## Custom layouts

```lua
hl.layout.register("grid", {
    recalculate = function(ctx)
        local n = #ctx.targets
        if n == 0 then return end
        local cols = math.ceil(math.sqrt(n))
        for i, target in ipairs(ctx.targets) do
            target:place(ctx:grid_cell(i, cols))
        end
    end,
    layout_msg = function(ctx, msg)
        -- handle hl.dsp.layout(msg) calls
    end,
})
```

---

## Patterns & idioms

**Hostname detection (io.popen is blocked):**
```lua
local f = io.open("/etc/hostname", "r")
local hostname = f and f:read("*l") or ""
if f then f:close() end
local is_work_laptop = (hostname == "magneto")
```

**Dedup before launch:**
```lua
local function launch_if_absent(class_fragment, cmd)
    for _, w in ipairs(hl.get_windows()) do
        if w.class:find(class_fragment) then return end
    end
    hl.exec_cmd(cmd)
end
```

**Monitor hot-plug handler:**
```lua
local work_desc = "Dell Inc. DELL P2217H 0G2TG68C266T"  -- strip "desc:" prefix
hl.on("monitor.added", function(monitor)
    if monitor.description == work_desc then
        launch_work_apps()
    end
end)
```

**Layout-aware bind:**
```lua
local function layout_bind(tbl)
    return function()
        local ws = hl.get_active_special_workspace() or hl.get_active_workspace()
        if ws and tbl[ws.tiled_layout] then
            hl.dispatch(tbl[ws.tiled_layout])
        end
    end
end

hl.bind("SUPER + D", layout_bind({
    scrolling = hl.dsp.layout("swapcol r"),
    dwindle   = hl.dsp.layout("togglesplit"),
    master    = hl.dsp.layout("cyclenext"),
}))
```

**Multi-dispatch in one bind (float + center):**
```lua
hl.bind("SUPER + F", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.center())
end)
```

**Target specific window in dispatcher:**
```lua
hl.dispatch(hl.dsp.window.move({
    window    = "address:" .. w.address,
    workspace = "special:minimize",
}))
```

**Minimize via special workspace:**
```lua
hl.bind("SUPER + X", function()
    hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
    hl.dispatch(hl.dsp.window.move({ workspace = "+0" }))
    hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
    hl.dispatch(hl.dsp.window.move({ workspace = "special:minimize" }))
    hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
end)
```

**Timer animation loop:** `hl.timer(fn, {timeout=16, type="repeat"})` → returns handle; `timer:set_enabled(false)` to stop. Use `math.randomseed(os.time())` for randomness (`Date.now()` is unavailable).

**Launch with window rule:** `hl.dsp.exec_cmd("alacritty", { float = true })` or `{ workspace = "4 silent" }`.

**Loop over directions:**
```lua
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind("SUPER + " .. dir,         hl.dsp.focus({ direction = dir }))
    hl.bind("SUPER + SHIFT + " .. dir, hl.dsp.window.swap({ direction = dir }))
end
```
