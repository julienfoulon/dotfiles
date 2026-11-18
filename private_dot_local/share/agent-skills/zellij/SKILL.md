---
name: zellij
description: Use when the user mentions zellij, panes, tabs, sessions or layouts; asks to run or watch something "in another pane", "in a split", "in a new tab"; wants to read what a TUI or REPL shows, send keystrokes to a running program, drive or monitor another agent session (claude, codex) in a pane, ask the user something via a popup; or wants to change zellij configuration, keybindings, themes, layouts or the web server (config.kdl, layouts/*.kdl).
---

# Controlling zellij (0.46)

Every pane action takes an explicit target (`-p terminal_N`) and pane/tab
creation takes `--no-focus`, so you never need to touch the user's focus.
Configuration is covered in [config.md](config.md) — read it before editing
`config.kdl`, a layout, or keybindings.

**Versions:** magneto and noble both run 0.46 (check `zellij --version`).
Items marked *(0.46)* fail on older versions with "unrecognized subcommand".

## Orient first

- `$ZELLIJ_SESSION_NAME` — your session (unset ⇒ you are outside zellij:
  prefix every command with `zellij -s <session>`)
- `terminal_$ZELLIJ_PANE_ID` — **your own pane**

```sh
zellij list-sessions -n                 # -s: names only
zellij action list-panes -t -c -s       # tab, command, focused/floating/exited (-a all, -j JSON)
zellij action list-tabs -s -p           # TAB_ID (stable), position, pane counts
zellij action dump-layout               # full layout as KDL
```

Tab **IDs** are stable; tab **positions** shift. Use `--tab-id`, `go-to-tab-by-id`, `close-tab-by-id`.

## Safety rules

- **Never write to your own pane** — the characters land in your own prompt.
- **Always pass `-p terminal_N`** to write/write-chars/send-keys/paste/dump-screen/close-pane.
  Without it they hit whatever pane the user is looking at.
- Spawn your own pane rather than typing into one you didn't create, unless the
  task *is* driving that program — then `dump-screen` it first.
- `kill-session`, `delete-session`, `close-tab*`, `close-pane` on panes you
  didn't create destroy user state — only on explicit request.

## Run a command in a new pane

`zellij run` prints the new pane id. Always add `--no-focus`:

```sh
PANE=$(zellij run --no-focus -n build -- make -j4)          # → terminal_7
zellij run --no-focus -f --width 80% --height 80% -n logs -- journalctl -fu docker
zellij run --no-focus --tab-id 2 -d down --cwd ~/src -- uv run pytest
zellij run --no-focus -c --block-until-exit -- ./slow.sh; echo $?   # waits; exit code = the command's
TAB=$(zellij action new-tab --no-focus -n bg -- htop)       # prints the new TAB_ID
```

`-c` closes the pane on exit; without it an exited pane stays (EXITED=true) so
its output can still be dumped. Other waits: `--blocking` (until pane closed),
`--block-until-exit-success|-failure`. `--notify` *(0.46)* watches the pane (see Attention).

## Type into a pane

`write-chars` types **without** Enter. Submit with `write -p <id> 13` (CR).
`write-chars "\n"` is a line feed: it only inserts a newline in the claude TUI.

```sh
zellij action write-chars -p terminal_7 'print(6*7)'
zellij action write -p terminal_7 13
zellij action send-keys -p terminal_7 "Ctrl c"        # Enter, Esc, Tab, Up, F1, "Alt Shift b"…
zellij action paste -p terminal_7 "$multiline"        # bracketed paste: REPLs, editors
```

Single-quote literals; the shell eats `$`, `!`, `"` otherwise.

**pane-send** wraps type + submit with stdin quoting and an own-pane guard —
prefer it for driving a REPL, a TUI or another `claude`:

```sh
PS=~/.local/share/agent-skills/zellij/scripts/pane-send     # this skill's scripts/ dir
bash $PS --enter terminal_7 'echo hello'
printf '%s' "$briefing" | bash $PS --enter 7
bash $PS --clear --enter 7 'retry'                           # Ctrl+u first
```

## Read a pane

```sh
zellij action dump-screen -p terminal_7                       # viewport → stdout
zellij action dump-screen -p terminal_7 -f --path out.txt     # full scrollback → file (-a keeps ANSI)
zellij subscribe -p terminal_7 -f json                        # stream of {"event":"pane_update","viewport":[…]}
```

- `dump-screen` works on `terminal_N` only (`plugin_N` returns nothing) and
  always reflects the current state — use it after every interaction.
- `subscribe` streams updates **only while a client is attached** to the
  session; in a detached session you get the initial frame, then nothing.
  Use it to follow an attached session; otherwise poll `dump-screen`:

```sh
for i in $(seq 30); do zellij action dump-screen -p "$PANE" | grep -q PASSED && break; sleep 2; done
```

## Attention: is that agent done? *(0.46)*

Claude Code (≥ 2.1.295), Codex and other agents report their state via OSC 7501;
zellij also tracks command exits, bells and notifications. Read it from JSON:

```sh
zellij action list-panes -j | jq -r '.[] | select(.is_plugin|not)
  | [.id, .title, .attention.status, (.attention.remembered.status // "-"), .attention.text] | @tsv'
```

- `status` is live: `Working`, `NeedsYou` (text `needs approval: …`), `Idle`, or
  `Failed` for a command pane that exited non-zero.
- Finished states move to `remembered.status` (`Done`/`Failed`) while
  `status` drops back to `Idle` — check both. `seen` tells whether the user saw it.
- `watch-pane -p <id>` toggles watching (going quiet then counts as NeedsYou);
  `mute-pane|mute-tab|mute-session`, `mark-pane-seen -p <id>`.
- Report your own script's state: `printf '\e]7501;state=working:msg=%s\e\\' "$(printf 'Syncing' | base64)"`
  (states: idle, working, done, blocked, error, clear).

## Ask the user via a popup *(0.46)*

`zellij prompt` must run **inside a pane** (needs `$ZELLIJ_PANE_ID`) of a session with an attached client.
Exit codes: 0 answered, 1 cancelled, 2 error, 124 timeout without default.

```sh
zellij prompt confirm "Force push?" --yes Push --no Cancel --timeout 60s
zellij prompt choose < branches.txt            # also: input, number, toggle, select, menu, form --spec f.json
zellij prompt notify "Build finished" --timeout 5s   # non-blocking, exits 0 at once
```

## Nested sessions (zellij over ssh)

A zellij started inside a pane (eg. `ssh -t host zellij attach x`) announces
itself to the outer one (0.45+, works over ssh, eg. magneto ↔ noble).
Outer `list-panes -j` shows it as `nested_session_name`; logs show
`nested session handshake` on both sides. `nested_session_handling`
(`ask`|`fullscreen`|`descend`|`never`) decides what focusing the pane does.

While descended, **all keys go to the guest**: `FocusHostSession` (ascend) must
be bound in the **guest's** config. Configs frozen with `clear-defaults=true`
lack the default `Ctrl o` + `]` / `[` / `f`; on magneto and noble they are
bound to `Ctrl o` + `k` (ascend) / `j` (descend) / `f` (host fullscreen).
Clicking the session breadcrumb in the tab bar also ascends.

## Cleanup

`close-pane -p <id>` for panes you created. Gentler: `send-keys -p <id> "Ctrl c"`
then `write-chars -p <id> exit` + `write -p <id> 13`. Tabs: `close-tab-by-id <TAB_ID>`.

## Common mistakes

| Mistake | Fix |
|---|---|
| `zellij run` without `--no-focus` steals the user's focus | always `--no-focus` (0.45+) |
| `write-chars "...\n"` to submit | `write -p <id> 13` |
| Waiting on `subscribe` in a detached session | poll `dump-screen` |
| `new-tab`/`prompt` against a session with no client attached | tabs created there vanish, prompt exits 2 — needs an attached client |
| `Z="zellij action"; $Z …` in zsh | zsh doesn't word-split: use an array, a function, or `bash -c` |
| Reading `attention.status` only | also read `attention.remembered.status` |

## Known environments

- **noble** (0.46): dev session `vb-dev`, layout `~/.config/zellij/layouts/vb-dev.kdl` —
  tabs `claude` (dispatcher session), `core`, `api`, `proxy` (repos under
  `~/gerrit/`), `run` (lazydocker + shell); tab bar is the `zellaude.wasm` plugin. Launched via
  `vb-dev` on magneto (`~/.local/bin/vb-dev` = `ssh -t noble.lab ~/tool/vb-dev`; bare
  `ssh noble vb-dev` fails, `~/tool` isn't in the ssh PATH); if `zellij list-sessions` doesn't show it,
  it isn't running — don't recreate it yourself, its launcher (`~/tool/vb-dev`)
  does more than attach.
- **zod**: `zellij web` behind nginx at `https://zod.lab/daily` (session `daily`), see CLAUDE.md.
