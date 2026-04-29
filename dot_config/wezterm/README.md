# WezTerm Configuration

> Personal WezTerm config, based on [KevinSilvester/wezterm-config](https://github.com/KevinSilvester/wezterm-config), extended for a Zellij + git worktree workflow.

Managed via [chezmoi](https://www.chezmoi.io/). macOS only.

---

## Workflow

The config is built around a **project/worktree** model:

- Each project lives at `~/code/<org>/<repo>` (or `~/code/<repo>`).
- Feature branches are checked out as git worktrees at `<project>/.worktrees/<branch>`.
- Each worktree gets its own **Zellij tab** named `org/repo/branch`, all within a single Zellij session per project.
- WezTerm **workspaces** map 1:1 to Zellij sessions.

### Starting a new branch

`Cmd+T` opens a two-step fzf picker: choose a project, then choose or type a branch name. It creates the worktree and opens a new Zellij dev tab at that path.

- `ctrl-r` in the branch picker loads remote branches; `ctrl-l` returns to local.

### Navigating

| Binding | Action |
| --- | --- |
| `Cmd+Ctrl+J` | Session picker — switch between WezTerm workspaces / Zellij sessions (`ctrl-d` deletes, `ctrl-n` new worktree) |
| `Cmd+Ctrl+P` | Project picker — open a directory as a new workspace |
| `Cmd+N` | New WezTerm window with project picker |
| `Cmd+Ctrl+E` | Tab picker — fzf over Zellij tabs in the current session (`ctrl-d` closes tab + removes worktree) |
| `Cmd+Ctrl+;` | Toggle back to previous workspace |

---

## Key Bindings

> **Modifier notation** — on macOS: `Cmd` = SUPER, `Cmd+Ctrl` = SUPER_REV, `LEADER` = Cmd+Ctrl+A

### Utility

| Keys | Action |
| --- | --- |
| `F1` | Copy mode |
| `F2` | Command palette |
| `F3` | Launcher |
| `F4` | Launcher (tabs) |
| `F5` | Launcher (workspaces) |
| `F11` / `Ctrl+Shift+F` | Toggle full screen |
| `F12` | Debug overlay |
| `Cmd+F` | Search (case-insensitive) |
| `Cmd+Ctrl+U` | Open selected URL |
| `Cmd+K` | Clear screen |
| `Cmd+V` | Paste from primary selection |

### Cursor Movement

| Keys | Action |
| --- | --- |
| `Cmd+Left` | Move to line start |
| `Cmd+Right` | Move to line end |
| `Opt+Left` | Move back one word |
| `Opt+Right` | Move forward one word |

### Tabs

| Keys | Action |
| --- | --- |
| `Cmd+T` | New worktree dev session (project → branch picker) |
| `Cmd+Ctrl+W` | Close current tab |
| `Cmd+[` / `Cmd+]` | Prev / next tab (delegates to Zellij when inside a session) |
| `Cmd+Ctrl+[` / `Cmd+Ctrl+]` | Move tab left / right |
| `Cmd+0` | Rename current tab |
| `Cmd+Ctrl+0` | Reset tab title |
| `Cmd+9` | Toggle tab bar |

### Window

| Keys | Action |
| --- | --- |
| `Cmd+N` | New window (project picker) |
| `Cmd+=` / `Cmd+-` | Grow / shrink window |

### Panes

All pane operations are Zellij-aware — they delegate to Zellij commands when a Zellij session is in the foreground.

| Keys | Action |
| --- | --- |
| `Cmd+\` | Split pane down |
| `Cmd+Ctrl+\` | Split pane right |
| `Cmd+Enter` | Maximise / unmaximise pane |
| `Cmd+W` | Close pane |
| `Opt+H/J/K/L` | Navigate panes (works across Zellij panes and nvim splits) |
| `Cmd+Ctrl+H/J/K/L` | Navigate panes (WezTerm-native, when not in Zellij) |

### Scrolling

| Keys | Action |
| --- | --- |
| `Cmd+U` | Scroll up 5 lines |
| `PageUp` / `PageDown` | Scroll 75% of viewport |
| `Opt+Shift+Up` / `Opt+Shift+Down` | Jump to previous / next shell prompt (requires OSC 133) |

### Backgrounds

| Keys | Action |
| --- | --- |
| `Cmd+/` | Random background |
| `Cmd+,` / `Cmd+.` | Cycle back / forward |
| `Cmd+Ctrl+/` | fzf background picker |
| `Cmd+B` | Toggle background focus |

### Key Tables (Leader mode)

Enter leader mode with `Cmd+Ctrl+A`, then:

| Key | Table | Actions |
| --- | --- | --- |
| `F` | `resize_font` | `K` larger · `J` smaller · `R` reset · `Esc`/`Q` exit |
| `P` | `resize_pane` | `H`/`J`/`K`/`L` resize · `Esc`/`Q` exit |
