# dotfiles

Personal dotfiles for macOS — managed with [chezmoi](https://chezmoi.io) in symlink mode.

## Stack

```
WezTerm  (terminal + workspaces)
  └── Zellij  (session manager + pane layout)
        ├── nvim   (editor, AstroNvim)
        ├── claude (AI assistant)
        └── terminal
```

## Fresh machine setup

```bash
curl -fsSL https://raw.githubusercontent.com/dave-kav/dotfiles/main/install.sh | bash
```

Installs: Xcode CLI tools → Homebrew → chezmoi → all configs → all brew packages → oh-my-zsh → plugins.

After running, complete the manual steps printed at the end (GPG key, shell restart).

## Day-to-day

Configs are symlinked — edit them in place as normal. To back up changes:

```bash
cd ~/.local/share/chezmoi
git add -p && git commit -m "..." && git push
```

On another machine: `chezmoi update` to pull and re-apply.

## Layout

| Repo path | Manages |
|-----------|---------|
| `dot_config/nvim/` | `~/.config/nvim/` |
| `dot_config/wezterm/` | `~/.config/wezterm/` (includes backdrops) |
| `dot_config/zellij/` | `~/.config/zellij/` |
| `dot_config/starship.toml` | `~/.config/starship.toml` |
| `dot_zshrc` | `~/.zshrc` |
| `dot_gitconfig` | `~/.gitconfig` |
| `dot_gitignore` | `~/.gitignore` |
| `dot_claude/settings.json` | `~/.claude/settings.json` |

## Zellij plugins

Downloaded by `install.sh` — not committed to git:

- [zjstatus](https://github.com/dj95/zjstatus) — status bar
- [zellij-attention](https://github.com/KiryuuLight/zellij-attention) — Claude Code tab notifications (⏳/✅)

To upgrade: delete the `.wasm` files from `~/.config/zellij/plugins/` and re-run `install.sh`.

## Shell history

Managed locally via [atuin](https://atuin.sh). To sync across machines:

```bash
atuin register  # or: atuin login
atuin sync
```

History is end-to-end encrypted.
