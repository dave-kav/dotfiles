# Dotfiles Monorepo — Design Spec

**Date:** 2026-04-13
**Status:** Approved

---

## Overview

Consolidate three separate config repos (nvim, wezterm, zellij) plus starship, shell config, and bin scripts into a single chezmoi-managed monorepo (`dave-kav/dotfiles`). A single `install.sh` bootstraps a fresh macOS machine end-to-end.

---

## Goals

- One `git push` to back up all config changes
- One command to set up a new machine from scratch
- No sensitive data in the repo
- Symlink mode: edit configs in place without any `chezmoi re-add` ceremony
- Idempotent install — safe to re-run

---

## Repo Structure

```
dotfiles/
├── install.sh                        # bootstrap script
├── Brewfile                          # full brew bundle manifest
├── .chezmoi.toml.tmpl                # chezmoi config
├── .chezmoiattributes                # sets symlink mode for all managed files
├── .chezmoiignore                    # excludes lazy-lock.json, backdrops handled separately
├── README.md
└── dot_config/
    ├── nvim/                         # → ~/.config/nvim/
    ├── wezterm/                      # → ~/.config/wezterm/ (includes backdrops/)
    ├── zellij/                       # → ~/.config/zellij/ (excludes plugins/*.wasm)
    └── starship.toml                 # → ~/.config/starship.toml
├── dot_zshrc                         # → ~/.zshrc
├── dot_gitconfig                     # → ~/.gitconfig
├── dot_gitignore                     # → ~/.gitignore
```

---

## chezmoi Configuration

### `.chezmoi.toml.tmpl`

```toml
[data]
    name = "Dave Kavanagh"

[diff]
    pager = "less -R"
```

### `.chezmoiattributes`

```
* mode=symlink
```

This makes chezmoi create symlinks for all managed files/directories rather than copies. Editing `~/.config/nvim/init.lua` directly edits the chezmoi source — no `chezmoi re-add` needed.

### `.chezmoiignore`

```
dot_config/nvim/lazy-lock.json
dot_config/zellij/plugins/*.wasm
```

`lazy-lock.json` changes frequently and is machine-specific. Wasm plugin binaries are downloaded by the install script instead.

---

## Managed Files

| Source in repo | Destination on disk |
|----------------|---------------------|
| `dot_config/nvim/` | `~/.config/nvim/` |
| `dot_config/wezterm/` | `~/.config/wezterm/` (includes `backdrops/`) |
| `dot_config/zellij/` | `~/.config/zellij/` (wasm excluded via `.chezmoiignore`) |
| `dot_config/starship.toml` | `~/.config/starship.toml` |
| `dot_zshrc` | `~/.zshrc` |
| `dot_gitconfig` | `~/.gitconfig` |
| `dot_gitignore` | `~/.gitignore` |

### Not managed (intentionally out of scope)

- Shell history (`~/.zsh_history`) — defer to atuin sync
- `~/bin/functions.sh` — dropped (see below)
- Cursor/Raycast/Zed configs — YAGNI
- SSH keys and private credentials
- `~/.gitconfig.whatnot` — work-specific conditional include, stays local

---

## .zshrc Changes

The following changes are made before committing:

| # | Change |
|---|--------|
| 1 | Remove hardcoded `/Users/davekavanagh/.bun/_bun` line |
| 2 | Remove `source ~/bin/functions.sh` line |
| 3 | Remove dead Fig block (`~/.fig/shell/zshrc.post.zsh`) |
| 4 | Wrap `zsh-syntax-highlighting` source in `[[ -f ... ]] &&` guard |
| 5 | Wrap `prompts` PATH export in `[[ -d ... ]] &&` guard |
| 6 | Wrap `prompts` completions source in `[[ -f ... ]] &&` guard |
| 7 | Inline `~/bin` PATH addition (was in `functions.sh`) |
| 8 | Inline `ap` AWS profile completion (was in `functions.sh`) |

---

## functions.sh

Dropped from the repo. It was almost entirely sourcing company-specific scripts that won't exist on other machines. The two portable pieces are inlined into `.zshrc` directly (PATH addition and `ap` completion).

---

## Brewfile

Auto-generated from current system state via `brew bundle dump`. Committed as-is. Covers taps, formulae, casks, VS Code extensions, go tools, and uv tools.

---

## Binary Assets

| Asset | Approach |
|-------|----------|
| WezTerm backdrops (`dot_config/wezterm/backdrops/`) | Committed to repo (~18MB, changes rarely) |
| Zellij wasm plugins (`zjstatus`, `zjstatus-hints`, `zellij-attention`) | Downloaded by install script from GitHub releases, excluded via `.chezmoiignore` |

---

## Install Script

`install.sh` — idempotent, macOS only. Each step is guarded so re-runs are safe.

### Steps in order

1. **Xcode CLI tools**
   Check `xcode-select -p` first; if missing, run `softwareupdate --install -a` (non-interactive)

2. **Homebrew**
   Skip if `brew` already in PATH; otherwise run official install script

3. **chezmoi**
   `brew install chezmoi` (idempotent)

4. **Apply dotfiles**
   `chezmoi init --apply --ssh dave-kav/dotfiles`
   On re-run: `chezmoi apply` (init is skipped if source already exists)
   Note: requires SSH key configured before running

5. **Brew bundle**
   `brew bundle --file="$(chezmoi source-path)/Brewfile" --no-lock`

6. **oh-my-zsh**
   Skip if `~/.oh-my-zsh` already exists; otherwise install via official curl script with `RUNZSH=no` (non-interactive)

7. **alias-tips plugin**
   Clone `https://github.com/djui/alias-tips` into `~/.oh-my-zsh/custom/plugins/alias-tips` if not already present

8. **Zellij wasm plugins**
   Download `zjstatus.wasm`, `zjstatus-hints.wasm`, and `zellij-attention.wasm` from their respective GitHub release URLs into `~/.config/zellij/plugins/` if not already present

9. **Font cache flush**
   `sudo atsutil server -shutdown` to pick up any newly installed fonts

10. **Print manual reminder**
    Output a checklist:
    - Restart terminal
    - Import GPG key (`gpg --import`) — required for git commit signing
    - Set up SSH key if not done (`ssh-keygen -t ed25519`)
    - Set default shell if needed (`chsh -s $(which zsh)`)
    - Run `atuin register` / `atuin login` + `atuin sync` when ready for history sync
    - Archive `dave-kav/wezterm-config` on GitHub and update its README to point here

---

## Git History

Fresh start. The three existing repos have 4–6 commits each; migrating history adds complexity for minimal value. The existing `dave-kav/wezterm-config` GitHub repo will be archived with a README pointing to the new monorepo.

---

## Out of Scope (Deferred)

- **atuin sync** — atuin installed and running locally. Uses end-to-end encryption. When ready: `atuin register`, `atuin login`, `atuin sync`, add `~/.config/atuin/config.toml` to chezmoi.
- **macOS system defaults** — skeleton exists in `laptop_setup-main` but is mostly empty; not worth including until real preferences are defined.
- **Linux support** — macOS only.
