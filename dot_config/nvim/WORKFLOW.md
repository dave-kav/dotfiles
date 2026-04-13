# Dev Workflow: WezTerm → Zellij → nvim

## The Stack

```
WezTerm  (terminal window + workspaces + backdrops)
  └── Zellij  (tab/pane layout, session manager)
        ├── nvim  (editor, left 2/3)
        ├── claude  (AI, top-right 1/3)
        └── terminal  (bottom-right 1/3)
```

---

## Shell Aliases & Functions

| Command | Action |
|---------|--------|
| `dev` | Attach/create zellij dev session named after cwd |
| `dev my-name` | Attach/create named dev session |
| `zj` | Fuzzy-pick and attach to existing zellij session |
| `zjd` | Fuzzy-pick and delete a zellij session |
| `worktree <branch>` | Create git worktree, copy `.envrc.local`, run `task setup` |
| `workflow` | Open this doc in MarkText |

---

## WezTerm Bindings (`Cmd` = macOS Super key)

### Sessions & Projects
| Key | Action |
|-----|--------|
| `Cmd+Ctrl+p` | Pick project → new WezTerm workspace + zellij dev session |
| `Cmd+Ctrl+f` | Fuzzy switch between workspaces |
| `Cmd+Ctrl+r` | Rename current workspace |
| `F5` | Workspace switcher |

### Tabs
| Key | Action |
|-----|--------|
| `Cmd+t` | New tab (auto-opens zellij session picker) |
| `Cmd+D` | New tab: zellij dev layout in current dir |
| `Cmd+w` | Close current pane |
| `Cmd+Ctrl+w` | Close current tab |
| `Cmd+[` / `Cmd+]` | Previous / next tab |
| `Cmd+Ctrl+[` / `Cmd+Ctrl+]` | Move tab left / right |

### Backgrounds
| Key | Action |
|-----|--------|
| `Cmd+/` | Random background |
| `Cmd+,` / `Cmd+.` | Cycle background back / forward |
| `Cmd+Ctrl+/` | Pick background from list |
| `Cmd+b` | Toggle focus mode (dimmed background) |

### WezTerm Panes (rarely needed — use zellij instead)
| Key | Action |
|-----|--------|
| `Cmd+\` | Split vertically |
| `Cmd+Ctrl+\` | Split horizontally |
| `Cmd+Ctrl+h/j/k/l` | Navigate panes |
| `Cmd+Enter` | Zoom/maximise pane (zellij-aware: sends `Alt+m` when in zellij) |

### Misc
| Key | Action |
|-----|--------|
| `F1` | Copy mode (vim bindings) |
| `F2` | Command palette |
| `F11` | Fullscreen |
| `Cmd+f` | Search scrollback |
| `Cmd+k` | Clear scrollback |
| `Shift+click` | Open link |

---

## Zellij

### The key rule: `Ctrl+g` toggles zellij on/off
- **Default (locked mode)** — all keys pass through to nvim/terminal.
- **Press `Ctrl+g`** — enter normal mode to manage panes/tabs/sessions.
- **Press `Ctrl+g` again** — back to locked.

### Always available (locked + all modes)
| Key | Action |
|-----|--------|
| `Alt+h/j/k/l` | Move focus between panes (works across nvim splits too) |
| `Alt+m` | Toggle fullscreen pane |
| `Ctrl+/` | Open keybinding reference (floating panel) |

### Always available (all modes except locked)
| Key | Action |
|-----|--------|
| `Ctrl+g` | Back to locked mode |
| `Ctrl+p` | Enter pane mode |
| `Ctrl+t` | Enter tab mode |
| `Ctrl+n` | Enter resize mode |
| `Ctrl+h` | Enter move mode |
| `Ctrl+s` | Enter scroll mode |
| `Ctrl+o` | Enter session mode |
| `Alt+d` | New pane (down) |
| `Alt+r` | New pane (right) |
| `Alt+n` | New pane |
| `Alt+f` | Toggle floating panes |
| `Alt+[` / `Alt+]` | Cycle swap layouts |
| `Ctrl+q` | Detach from session |
| `Ctrl+Shift+q` | Quit zellij |

### Pane mode (`Ctrl+p`)
| Key | Action |
|-----|--------|
| `h/j/k/l` | Move focus |
| `d` | New pane down |
| `r` | New pane right |
| `s` | New pane stacked |
| `n` | New pane |
| `x` | Close focused pane |
| `f` | Toggle fullscreen |
| `z` | Toggle pane frames |
| `e` | Embed / make floating |
| `w` | Toggle floating panes |
| `i` | Pin pane |
| `c` | Rename pane |
| `p` | Switch focus |

### Tab mode (`Ctrl+t`)
| Key | Action |
|-----|--------|
| `h/k` or `←/↑` | Previous tab |
| `l/j` or `→/↓` | Next tab |
| `1–9` | Go to tab N |
| `n` | New tab |
| `x` | Close tab |
| `r` | Rename tab |
| `b` | Break pane to new tab |
| `[` / `]` | Break pane left / right |
| `s` | Sync tab (broadcast input) |
| `tab` | Toggle between last two tabs |

### Resize mode (`Ctrl+n`)
| Key | Action |
|-----|--------|
| `h/j/k/l` | Grow pane left/down/up/right |
| `H/J/K/L` | Shrink pane left/down/up/right |
| `+` / `-` | Grow / shrink |

### Move mode (`Ctrl+h`)
| Key | Action |
|-----|--------|
| `h/j/k/l` | Move pane in direction |
| `n` / `tab` | Move pane forward |
| `p` | Move pane backward |

### Scroll mode (`Ctrl+s`)
| Key | Action |
|-----|--------|
| `j/k` | Scroll down/up |
| `d/u` | Half-page down/up |
| `PageDown/PageUp` | Full page |
| `s` | Enter search |
| `e` | Edit scrollback in `$EDITOR` |

### Search mode (from scroll → `s`)
| Key | Action |
|-----|--------|
| `n` / `p` | Next / previous match |
| `c` | Toggle case sensitivity |
| `o` | Toggle whole word |
| `w` | Toggle wrap |

### Session mode (`Ctrl+o`)
| Key | Action |
|-----|--------|
| `d` | Detach from session |
| `w` | Session manager (switch/kill sessions) |
| `c` | Configuration / keybinding reference |
| `a` | About |
| `p` | Plugin manager |

### Status bar (zjstatus)
- **Dev sessions**: bar is invisible while in locked mode (nvim handles status). Mode badge appears when you enter pane/tab/etc mode. Hints show on the right.
- **Plain sessions**: full bar — mode · session · tabs · git branch · dirty · time.

### Zellij attention (Claude Code)
When Claude needs input → ⏳ on tab
When Claude finishes → ✅ on tab
Focusing the pane clears the icon.

---

## nvim — Core Bindings (AstroNvim)

> **Leader = `<Space>`**
> Press `<Space>` and pause — which-key shows all available bindings.
> `<Space>fk` opens Legendary: fuzzy search every keymap and command.
> `:AstroReload` reloads config without restarting.

### File navigation
| Key | Action |
|-----|--------|
| `<Space><Space>` | Smart open (frecency) |
| `<Space>ff` | Find file (Telescope) |
| `<Space>fw` | Find word in project |
| `<Space>fo` | Recent files |
| `<Space>e` | Toggle neo-tree sidebar |
| `<Space>bb` | Switch buffer |
| `<Space>bc` | Close buffer |
| `<Space>P` | Project manager |

### LSP navigation
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `grr` | References (Telescope) |
| `gri` | Implementation (Telescope) |
| `grt` | Type definition (Telescope) |
| `grn` | Rename symbol (inline preview) |
| `gra` | Code action |
| `K` | Hover docs |
| `<Space>lf` | Format file |
| `<Space>ld` | Hover diagnostics |
| `[e` / `]e` | Previous / next error |
| `[w` / `]w` | Previous / next warning |

### Jump navigation
| Key | Action |
|-----|--------|
| `Ctrl+o` / `Ctrl+i` | Jump back / forward (Portal popup) |
| `s` + 2 chars | Leap: jump anywhere visible |
| `Ctrl+d` / `Ctrl+u` | Half page down / up |

### Pane / split navigation
| Key | Action |
|-----|--------|
| `Alt+h/j/k/l` | Move between nvim splits and zellij panes seamlessly |

---

## nvim — Plugin Bindings

### Git (`<Space>g`)
| Key | Action |
|-----|--------|
| `<Space>gg` | Lazygit |
| `<Space>gj` / `<Space>gk` | Next / prev hunk |
| `<Space>gs` | Stage hunk |
| `<Space>gr` | Reset hunk |
| `<Space>gb` | Blame line |
| `<Space>gy` | Copy git permalink |
| `<Space>gY` | Open git permalink in browser |
| `<Space>gv` | Diffview: side-by-side diff |
| `<Space>gH` | Diffview: file history |

### Tests (`<Space>T`) — Python only
| Key | Action |
|-----|--------|
| `<Space>Tt` | Run nearest test |
| `<Space>Tf` | Run test file |
| `<Space>Ts` | Test summary panel |
| `<Space>To` | Test output panel |
| `<Space>TS` | Stop tests |
| `]t` / `[t` | Next / prev failed test |

Uses `uv run pytest` when `pyproject.toml` is found.

### Notes (`<Space>N`) — obsidian.nvim
| Key | Action |
|-----|--------|
| `<Space>Nd` | Today's daily note |
| `<Space>Ny` | Yesterday's note |
| `<Space>Nn` | New note |
| `<Space>Nf` | Search notes |
| `<Space>No` | Quick switch by title |
| `<Space>Nb` | Backlinks |
| `<Space>Nt` | Browse by tag |
| `[[` | Insert wikilink (autocompletes) |

Vault: `~/notes/` — plain markdown, works with/without Obsidian app.

### Diagnostics & Lists (`<Space>x`)
| Key | Action |
|-----|--------|
| `<Space>xx` | Trouble: all diagnostics |
| `<Space>xd` | Trouble: buffer diagnostics |
| `<Space>xL` | Trouble: LSP definitions/references |
| `<Space>xs` | Trouble: symbols |

### Refactoring (`<Space>r`)
| Key | Mode | Action |
|-----|------|--------|
| `<Space>rr` | n/v | All valid refactors for selection |
| `<Space>re` | visual | Extract to function |
| `<Space>rv` | visual | Extract to variable |
| `<Space>ri` | n/v | Inline variable |

### GitHub (`<Space>O`)
| Key | Action |
|-----|--------|
| `<Space>Op` | List open PRs |
| `<Space>Oi` | List issues |
| `<Space>Or` | Start PR review |
| `<Space>Oa` | Add assignee |

### Search & Replace
| Key | Action |
|-----|--------|
| `<Space>sr` | Grug-far: project-wide search & replace |

### Misc
| Key | Action |
|-----|--------|
| `<Space>U` | Undotree |
| `<Space>tw` | Twilight: dim code outside current block |
| `<Space>mp` | Markdown preview (`.md` files) |
| `<Space>fml` | 🌧 make it rain |
| `gcc` / `gc` | Toggle comment line / selection |
| `Ctrl+n` | Multiple cursors |

---

## nvim — Always-on Plugins

| Plugin | What it does |
|--------|-------------|
| `vim-illuminate` | Highlights all occurrences of word under cursor |
| `modicator` | Line number colour changes with mode |
| `tint.nvim` | Dims inactive splits |
| `mini.indentscope` | Animated scope line |
| `nvim-treesitter-context` | Sticky class/function header |
| `satellite.nvim` | Scrollbar with diagnostics, git hunks, search results |
| `rainbow-delimiters` | Colour-matched brackets |
| `hardtime` | Nudges toward better vim motions (`:Hardtime disable` to pause) |
| `indent-blankline` | Indent guide lines |

---

## Python LSP (Ruff + Zuban)

| Tool | Role |
|------|------|
| `ruff` | Diagnostics + formatting |
| `zuban` | Completions, go-to-definition, hover |

Both activated via `direnv` + nix shell.
Install: `uv tool install ruff && uv tool install zuban`

---

## Multi-worktree Claude Code workflow

```
WezTerm workspace: whatnot_backend
  └── zellij dev session
        ├── nvim  ← main branch
        └── claude

WezTerm workspace: whatnot_backend_feat-tax  (worktree)
  └── zellij dev session
        ├── nvim  ← feat/offline-tax
        └── claude  ← separate context, no bleed
```

```bash
# Create worktree
worktree feat/offline-tax        # creates ../whatnot_backend_feat-offline-tax

# Open project workspaces via WezTerm picker (Cmd+Ctrl+p)
# Each workspace gets a deterministic background image
```

---

## Shell vi mode

The shell runs in vi mode. `Esc` enters normal mode, `i`/`a` back to insert.
Works in any zsh prompt — zellij panes, bare terminals, everywhere.
