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

## WezTerm Bindings (`Cmd` = macOS Super key)

### Sessions & Projects
| Key | Action |
|-----|--------|
| `Cmd+T` | Two-step worktree picker: choose project → choose/type branch, creates `.worktrees/<branch>` and opens a Zellij dev tab |
| `Cmd+Ctrl+E` | Tab picker — all Zellij tabs in current session. `ctrl-d` closes tab + removes worktree |
| `Cmd+Ctrl+J` | Session picker — WezTerm workspaces + detached Zellij sessions. `ctrl-n` new worktree, `ctrl-d` delete session |
| `Cmd+Ctrl+P` | Project picker — switch current window to a project workspace |
| `Cmd+N` | New WezTerm window with project picker |
| `Cmd+Ctrl+;` | Toggle back to previous workspace |
| `Cmd+Ctrl+R` | Rename current workspace |

### Tabs
| Key | Action |
|-----|--------|
| `Cmd+[` / `Cmd+]` | Previous / next tab (sends `Alt+[/]` to Zellij when inside it) |
| `Cmd+Ctrl+[` / `Cmd+Ctrl+]` | Move tab left / right |
| `Cmd+Ctrl+W` | Close current tab |

### Panes (Zellij-aware)
| Key | Action |
|-----|--------|
| `Cmd+\` | Split vertically (Zellij: new pane down) |
| `Cmd+Ctrl+\` | Split horizontally (Zellij: new pane right) |
| `Cmd+Enter` | Zoom/maximise pane (Zellij: `Alt+m`) |
| `Cmd+W` | Close pane (Zellij: close-pane) |
| `Cmd+Ctrl+H/J/K/L` | Navigate panes (WezTerm-native, when not in Zellij) |
| `Option+H/J/K/L` | Navigate panes (works across Zellij panes and nvim splits) |

### Backgrounds
| Key | Action |
|-----|--------|
| `Cmd+/` | Random background |
| `Cmd+,` / `Cmd+.` | Cycle background back / forward |
| `Cmd+Ctrl+/` | Pick background from list |
| `Cmd+B` | Toggle focus mode (dimmed background) |

### Misc
| Key | Action |
|-----|--------|
| `Cmd+F` | Search scrollback |
| `Cmd+K` | Clear scrollback |
| `Cmd+U` | Scroll up 5 lines |
| `Cmd+V` | Paste from primary selection |
| `Cmd+-` / `Cmd+=` | Shrink / grow window |
| `F1` | Copy mode (vim bindings) |
| `F2` | Command palette |
| `F11` / `Ctrl+Shift+F` | Fullscreen |
| `F12` | Debug overlay |
| `Shift+click` | Open link |

---

## Zellij

### The key rule: `Ctrl+g` toggles lock on/off
- **Default (locked mode)** — all keys pass through to nvim/terminal
- **`Ctrl+g`** — enter normal mode to manage panes/tabs/sessions
- **`Ctrl+g` again** — back to locked

### Always available (locked + all modes)
| Key | Action |
|-----|--------|
| `Alt+h/j/k/l` | Move focus between panes (works across nvim splits too) |
| `Alt+m` | Toggle fullscreen pane |
| `Alt+[` / `Alt+]` | Previous / next tab (locked mode only) |
| `Alt+1–9` | Go to tab N (locked mode only) |
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
| `Alt+d` | New pane down |
| `Alt+r` | New pane right |
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
| `h/j/k/l` | Grow pane in direction |
| `H/J/K/L` | Shrink pane in direction |
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

### Search (from scroll → `s`)
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
| `w` | Session manager |
| `c` | Configuration / keybinding reference |
| `p` | Plugin manager |

---

## nvim

> **Leader = `Space`** — press and pause to see which-key hints

### File navigation
| Key | Action |
|-----|--------|
| `Space Space` | Smart open (frecency + fzf) |
| `Space f f` | Find file |
| `Space f w` | Live grep |
| `Space f o` | Recent files |
| `Space f b` | Buffers |
| `Space f u` | Undo history |
| `Space f s` | Git status |
| `Space f r` | Resume last picker |
| `Space f '` | Marks/bookmarks |
| `Space f n` | Notifications |

### Buffers & windows
| Key | Action |
|-----|--------|
| `Shift+H` / `Shift+L` | Previous / next buffer |
| `]b` / `[b` | Next / prev buffer |
| `Space c` | Close buffer |
| `Space b n` | New buffer |
| `Space b p` | Pin buffer |
| `Space b o` | Close other buffers |
| `Space s v` | Split vertical |
| `Space s h` | Split horizontal |
| `Space s x` | Close window |
| `Alt+H/J/K/L` | Move between nvim splits and Zellij panes seamlessly |
| `Ctrl+Alt+H/J/K/L` | Resize splits |

### LSP
| Key | Action |
|-----|--------|
| `K` | Hover docs |
| `Ctrl+K` | Signature help |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `grr` | References |
| `gri` | Implementation |
| `gy` | Type definition |
| `grn` / `Space l r` | Rename symbol (inline preview) |
| `gra` / `Space l a` | Code actions |
| `Space l f` / `Space c f` | Format buffer |
| `Space l s` | Document symbols |
| `Space l S` | Workspace symbols |
| `Space l h` | Toggle inlay hints |
| `Space l i` | LSP info |
| `[d` / `]d` | Prev / next diagnostic |
| `[e` / `]e` | Prev / next error |
| `[w` / `]w` | Prev / next warning |
| `Space l D` | Buffer diagnostics (Telescope) |

### Diagnostics & Trouble
| Key | Action |
|-----|--------|
| `Space x x` | Trouble: all diagnostics |
| `Space x d` | Trouble: buffer diagnostics |
| `Space x L` | Trouble: LSP panel |
| `Space x s` | Trouble: symbols |

### Git
| Key | Action |
|-----|--------|
| `]h` / `[h` | Next / prev hunk |
| `Space g h s` | Stage hunk |
| `Space g h r` | Reset hunk |
| `Space g h S` | Stage buffer |
| `Space g h u` | Undo stage hunk |
| `Space g h b` | Blame line (full) |
| `Space g h p` | Preview hunk |
| `Space g h d` | Diff this |
| `Space g v` | Diffview open |
| `Space g H` | Diffview: file history |
| `Space g V` | Diffview close |
| `Space g y` | Copy git permalink |
| `Space g Y` | Open git permalink in browser |
| `Space t b` | Toggle inline blame |
| `Space t B` | Toggle gutter blame column |
| `ih` | Select hunk (text object, operator/visual) |

### GitHub (Octo)
| Key | Action |
|-----|--------|
| `Space O p` | PR list |
| `Space O i` | Issue list |
| `Space O r` | Start review |
| `Space O a` | Add assignee |

### Tests (Python / pytest)
| Key | Action |
|-----|--------|
| `Space T t` | Run nearest test |
| `Space T f` | Run test file |
| `Space T s` | Test summary panel |
| `Space T o` | Test output panel |
| `Space T S` | Stop tests |
| `]t` / `[t` | Next / prev failed test |

Uses `uv run python -m pytest` when `pyproject.toml` exists.

### Refactoring
| Key | Mode | Action |
|-----|------|--------|
| `Space r r` | n/v | Refactor picker |
| `Space r e` | visual | Extract to function |
| `Space r v` | visual | Extract to variable |
| `Space r i` | n/v | Inline variable |

### Notes (Obsidian)
| Key | Action |
|-----|--------|
| `Space N d` | Today's daily note |
| `Space N y` | Yesterday's note |
| `Space N n` | New note |
| `Space N f` | Search notes |
| `Space N o` | Quick switch |
| `Space N b` | Backlinks |
| `Space N t` | Browse by tag |
| `Space N c` | New on-call entry (prompts for ticket ID) |
| `Space N j` | Import Jira XML to on-call note |
| `Space m p` | Markdown preview toggle |

Vault: `~/notes/` — plain markdown.

### Search & Replace
| Key | Action |
|-----|--------|
| `Space s r` | Grug-far: project-wide search & replace |

### Sessions
| Key | Action |
|-----|--------|
| `Space S l` | Restore last session |
| `Space S s` | Restore session for cwd |
| `Space S d` | Don't save session on exit |

### Terminal
| Key | Action |
|-----|--------|
| `Ctrl+\` | Toggle terminal |
| `Space t h` | Terminal horizontal |
| `Space t v` | Terminal vertical |
| `Space t f` | Terminal float |

### Jump navigation
| Key | Action |
|-----|--------|
| `Ctrl+O` / `Ctrl+I` | Jump back / forward (Portal popup) |
| `s` + 2 chars | Leap: jump anywhere visible |

### Misc
| Key | Action |
|-----|--------|
| `Space U` | Undotree |
| `Space t w` | Twilight: dim outside current block |
| `Space t c` | Toggle CSV view (`.csv` files) |
| `Space i` | Toggle value under cursor (true↔false, yes↔no, etc.) |
| `Space w` | Save file |
| `Space q` | Quit |
| `Space f m l` | 🌧 make it rain |
| `jj` / `jk` | Exit insert mode |
| `<` / `>` | Indent left/right (stays in visual) |
| `Alt+J/K` | Move line(s) down/up |

---

## Multi-worktree workflow

`Cmd+T` is the entry point for all new work:

1. Press `Cmd+T` — fzf shows all git projects under `~/code`
2. Select a project
3. fzf shows local branches — select one or type a new name to create it
4. `ctrl-r` toggles to remote branches, `ctrl-l` back to local
5. WezTerm creates a new Zellij dev tab named `project/branch` with the dev layout, cwd set to the worktree

Worktrees live at `~/code/<project>/.worktrees/<branch>`.

To close a worktree tab and remove its directory:
→ `Cmd+Ctrl+E`, select the tab, press `ctrl-d`

---

## Zellij attention (Claude Code)

When Claude needs input → ⏳ appears on the tab
When Claude finishes → ✅ appears on the tab
Focusing the pane clears the icon.

---

## Shell vi mode

The shell runs in vi mode. `Esc` enters normal mode, `i`/`a` back to insert. Works in all zsh prompts.
