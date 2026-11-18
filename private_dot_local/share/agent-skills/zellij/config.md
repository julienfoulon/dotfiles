# Configuring zellij (0.46)

## Where things are

`zellij setup --check` prints the version and every directory in use. Defaults:

| What | Path |
|---|---|
| Config | `~/.config/zellij/config.kdl` (`-c` / `$ZELLIJ_CONFIG_FILE`) |
| Layouts | `~/.config/zellij/layouts/*.kdl` (`layout_dir`) |
| Themes | inline `themes {}` block, or files in `theme_dir` |
| Keybinding presets | `~/.config/zellij/keybinds/*.kdl` (`keybinds_dir`) — new in 0.46 |
| Session cache / resurrection | `~/.cache/zellij` |

On magneto and noble `config.kdl` and `catppuccin.kdl` are **managed by chezmoi**
(`~/.local/share/chezmoi/dot_config/zellij/`): edit the source, then `chezmoi apply`
— a direct edit of the target is overwritten on the next apply.

**Reference dumps** — the authority for option names and defaults on the
installed version; prefer them over memory:

```sh
zellij setup --dump-config                 # every option, commented, with defaults
zellij setup --dump-keybinds default       # a built-in preset ("default", "unlock-first")
zellij setup --dump-layout default         # also: compact, strider, …
zellij setup --clean                       # start ignoring the user config (bisect a bad config)
```

Validate after editing: `zellij setup --check` must say `[CONFIG FILE]: Well defined.`
For a candidate file: `zellij -c /path/new.kdl setup --check`. It catches KDL
syntax errors and unknown/malformed actions (with a pointer to the line), but
**not** unknown option names or theme names — those are silently ignored, so
compare option names against `--dump-config`.
Most options apply live to running sessions; those marked "(Requires restart)"
in `--dump-config` need a new session.

The 0.46 **settings screen** (right-click → Settings…, or Session mode) edits
the same file — it keeps comments, so hand edits and UI edits can coexist.

## Keybindings: presets (0.46)

Old configs (written by ≤ 0.44) contain a full `keybinds clear-defaults=true { … }`
copy of the defaults. That copy freezes the bindings: every binding added
later (FocusLastPane, WatchPane, ToggleBars, GoToNextAttention, ScrollToPrompt,
ToggleSession, …) is missing. 0.46 replaces this with presets plus overrides:

```kdl
// preset: "default" | "unlock-first" | a file name in keybinds_dir
keybinds preset="default" primary="Ctrl" secondary="Alt" {
    normal {
        bind "Ctrl Tab"       { GoToNextTab; }
        bind "Ctrl Shift Tab" { GoToPreviousTab; }
    }
    shared_except "locked" {
        unbind "Ctrl h"                        // free a key for vim/the shell
    }
}
```

- Bindings inside the block apply **on top of** the preset; add
  `clear-defaults=true` only when replacing the preset entirely.
- `{primary}` / `{secondary}` / `{unlock}` in a preset file stand for the leader keys.
- Mode blocks: `normal locked pane tab resize move scroll search entersearch
  renametab renamepane session tmux`, plus `shared`, `shared_except "m"…`, `shared_among "m"…`.
- Migrating an old full copy: diff it against `--dump-keybinds default`
  (normalise ordering first), keep only the lines that differ as overrides,
  and switch the header to `keybinds preset="default" {`.
- Per-session trial without editing: `zellij options --keybinds-preset unlock-first`.

Action syntax inside `bind`: PascalCase actions with args, `;`-terminated:
`NewPane "down"; SwitchToMode "normal";`, `Run "htop" { floating true; close_on_exit true; }`,
`LaunchOrFocusPlugin "session-manager" { floating true; move_to_focused_tab true; }`.
`Run` bindings get `$ZELLIJ_ORIGIN_PANE_ID` (the pane focused when pressed).

## Common options

```kdl
theme "catppuccin-mocha"            // pins one theme; disables dark/light auto-switching
// theme_dark "catppuccin-mocha"    // …or follow the host terminal's reported hue
// theme_light "catppuccin-latte"
default_layout "compact"
default_mode "normal"               // "locked" = unlock-first workflow
pane_frame_style "titles"           // 0.45+ default; "full" = classic border; "none"
copy_command "wl-copy"              // Wayland; else OSC 52 is used
scroll_buffer_size 10000
on_quit "ask_detach"                // ask_quit | ask_detach | quit | detach
session_serialization true          // resurrection (needs restart)
serialize_pane_viewport true
show_startup_tips false
show_release_notes false
bars_hidden_on_start "none"         // "all" or "tab-bar,status-bar" (0.46, toggle: Ctrl p Shift z)
scroll_mode_sync false              // 0.45.1: mouse scroll no longer enters Scroll mode
support_kitty_graphics_protocol true // kitty image protocol passed through to the host terminal; false to disable
```

**Plugin aliases** (`plugins {}`): 0.46 serves the bars from `zellij:bars` with a
`role`. An old block like `tab-bar location="zellij:tab-bar"` overrides that;
delete overrides you didn't customise — built-in aliases come back on their own.

**Attention** (inbox, markers, notifications): `attention { enabled true;
done_threshold_secs 10; track_commands false; idle_rule "all"; host_status true; }`.

**Web server**: `web_server`, `web_server_ip`, `web_server_port` (8082),
`web_server_cert`/`web_server_key` (required off-localhost),
`web_client { base_url "/zellij" }` behind a reverse proxy. Tokens:
`zellij web --create-token` / `--create-read-only-token` / `--list-tokens`.
Direct link to a session: `https://<host>[:port]/<session-name>`.

**Built-in terminal** (`zellij terminal`, 0.46): its own `terminal {}` block —
font, font_size, padding, opacity, `theme {}`, key chords. Doesn't affect the
multiplexer running inside another terminal.

## Themes

```kdl
themes {
    my-theme {
        fg "#cdd6f4"
        bg "#1e1e2e"
        red "#f38ba8"   // also: green yellow blue magenta orange cyan black white
    }
}
```

Colours as `"#rrggbb"` or `R G B`. Built-in themes exist (`default`,
`default-light`, `classic`, and many community ones); a misspelt name is not
reported by `--check`, so look at the result. The 0.46 settings screen has a
theme editor with contrast checks.
Runtime switch: `zellij action toggle-theme | set-dark-theme | set-light-theme`.

## Layouts

```kdl
layout {
    default_tab_template {                 // wraps every tab; children = tab body
        pane size=1 borderless=true { plugin location="tab-bar"; }
        children
        pane size=1 borderless=true { plugin location="status-bar"; }
    }
    tab name="code" cwd="~/src/app" focus=true {
        pane split_direction="vertical" {
            pane size="60%" command="nvim"
            pane { command "lazygit"; start_suspended true; }
        }
    }
    tab name="run" {
        pane command="make" { args "watch"; close_on_exit false; }
        floating_panes {
            pane command="htop" x="10%" y="10%" width="80%" height="80%"   // geometry = attributes, not child nodes
        }
    }
}
```

- `split_direction="vertical"` puts children side by side; default is stacked top/bottom.
- Sizes: integer rows/cols or `"N%"`. `borderless=true`, `stacked=true` (stacked panes).
- `command` panes: `args`, `cwd`, `close_on_exit`, `start_suspended`.
- Plugins: `plugin location="zellij:…"` / `"file:/abs/x.wasm"` / alias name.
- `swap_tiled_layout` / `swap_floating_layout` blocks define alternatives cycled
  with `NextSwapLayout` or applied by name: `zellij action apply-tiled-swap-layout <name>` (0.46).

Use it:

```sh
zellij -l mylayout                         # new session (outside zellij), or add as tab(s) inside one
zellij -n mylayout -s name                 # always a new session
zellij action new-tab -l mylayout -n name  # into the current session
zellij --layout-string 'layout { pane command="htop"; }'   # inline, no file
zellij action dump-layout > layouts/snapshot.kdl           # capture a live session as a layout
```

Test a layout without touching user sessions — start it in a throwaway pty
(starting a session needs a terminal; parse errors land in the transcript):

```sh
TERM=xterm-256color timeout 6 script -qfc "stty cols 120 rows 40; zellij -n ./file.kdl -s t" out.txt >/dev/null &
sleep 3; zellij -s t action list-panes -t -c -s     # did every tab/pane/command come up?
wait; zellij kill-session t; zellij delete-session t
```

## Startup / sessions

- Background session with a command: `zellij attach -b name -- htop` (0.45.1+).
- Resurrection: exited sessions show `(EXITED - attach to resurrect)` in `list-sessions`;
  `zellij attach name` restores it, commands start suspended (`-f` runs them).
  A program can set its own restart command: `zellij action set-resurrect-command -- cmd args` (0.46).
- Shell auto-start snippet: `zellij setup --generate-auto-start zsh`; completions: `--generate-completion zsh`.
