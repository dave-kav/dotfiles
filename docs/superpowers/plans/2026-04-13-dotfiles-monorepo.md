# Dotfiles Monorepo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate three separate config repos (nvim, wezterm, zellij) plus starship, shell, and git config into a single chezmoi-managed monorepo with a one-command bootstrap install script.

**Architecture:** chezmoi in symlink mode manages all configs from `~/.local/share/chezmoi/` (the dotfiles repo), creating symlinks at their target paths. `install.sh` bootstraps a fresh macOS machine end-to-end: Xcode CLI tools → Homebrew → chezmoi → apply configs → brew bundle → post-install steps.

**Tech Stack:** chezmoi 2.x, Homebrew, zsh, GitHub CLI (`gh`)

**Spec:** `docs/superpowers/specs/2026-04-13-dotfiles-design.md`

---

## File Map

| File in repo | Destination on disk | Notes |
|---|---|---|
| `.chezmoi.toml.tmpl` | chezmoi config | Author data |
| `.chezmoiattributes` | chezmoi config | Symlink mode |
| `.chezmoiignore` | chezmoi config | Minimal — wasm only |
| `.gitignore` | monorepo git tracking | Excludes .git dirs, lazy-lock, wasm |
| `dot_config/nvim/` | `~/.config/nvim/` | Excludes `.git/` via rsync |
| `dot_config/wezterm/` | `~/.config/wezterm/` | Includes `backdrops/` |
| `dot_config/zellij/` | `~/.config/zellij/` | Plugin paths de-hardcoded |
| `dot_config/starship.toml` | `~/.config/starship.toml` | |
| `dot_zshrc` | `~/.zshrc` | Cleaned up |
| `dot_gitconfig` | `~/.gitconfig` | attributesfile line removed |
| `dot_gitignore` | `~/.gitignore` | |
| `dot_claude/settings.json` | `~/.claude/settings.json` | Zellij hook wiring for Claude Code |
| `Brewfile` | repo root | Auto-generated |
| `install.sh` | repo root | Bootstrap script |
| `README.md` | repo root | |

---

## Task 1: Create the GitHub repo and initialise chezmoi

- [ ] **Step 1: Create the GitHub repo**

```bash
gh repo create dave-kav/dotfiles --public \
  --description "Personal dotfiles — nvim, wezterm, zellij, starship, shell"
```

- [ ] **Step 2: Initialise chezmoi pointing at the new remote**

```bash
chezmoi init git@github.com:dave-kav/dotfiles.git
```

Creates `~/.local/share/chezmoi/` as a git repo with the remote configured.

- [ ] **Step 3: Verify**

```bash
ls ~/.local/share/chezmoi/
git -C ~/.local/share/chezmoi remote -v
```

Expected: directory exists, remote shows `git@github.com:dave-kav/dotfiles.git`

---

## Task 2: Configure chezmoi and monorepo git

**Files:**
- Create: `~/.local/share/chezmoi/.chezmoi.toml.tmpl`
- Create: `~/.local/share/chezmoi/.chezmoiattributes`
- Create: `~/.local/share/chezmoi/.chezmoiignore`
- Create: `~/.local/share/chezmoi/.gitignore`

- [ ] **Step 1: Create `.chezmoi.toml.tmpl`**

```bash
cat > ~/.local/share/chezmoi/.chezmoi.toml.tmpl << 'EOF'
[data]
    name = "Dave Kavanagh"

[diff]
    pager = "less -R"
EOF
```

- [ ] **Step 2: Create `.chezmoiattributes` — enables symlink mode for all managed entries**

```bash
cat > ~/.local/share/chezmoi/.chezmoiattributes << 'EOF'
* mode=symlink
EOF
```

- [ ] **Step 3: Create `.chezmoiignore` — minimal: only entries chezmoi needs to skip**

```bash
cat > ~/.local/share/chezmoi/.chezmoiignore << 'EOF'
# Zellij wasm plugins are downloaded by install.sh
dot_config/zellij/plugins/*.wasm
EOF
```

Note: `.git` subdirs don't need to be in `.chezmoiignore` because we use `rsync --exclude='.git/'` when copying (Tasks 3–5), so they never enter the source directory.

- [ ] **Step 4: Create the monorepo's own `.gitignore`**

This keeps noisy or binary files out of the dotfiles repo's git tracking:

```bash
cat > ~/.local/share/chezmoi/.gitignore << 'EOF'
# nvim plugin lock file — machine-specific, changes frequently
dot_config/nvim/lazy-lock.json

# Zellij wasm plugins — downloaded by install.sh
dot_config/zellij/plugins/*.wasm
EOF
```

- [ ] **Step 5: Commit**

```bash
cd ~/.local/share/chezmoi
git add .chezmoi.toml.tmpl .chezmoiattributes .chezmoiignore .gitignore
git commit -m "chore: initialise chezmoi with symlink mode config"
```

---

## Task 3: Add nvim config

Use `rsync --exclude='.git/'` — never `cp -r`. Using `cp -r` would copy the `.git` directory, causing `git add` to silently skip the entire directory (git treats nested `.git` dirs as unregistered submodules).

- [ ] **Step 1: Sync nvim config into chezmoi source, excluding .git**

```bash
mkdir -p ~/.local/share/chezmoi/dot_config
rsync -a --exclude='.git/' ~/.config/nvim/ ~/.local/share/chezmoi/dot_config/nvim/
```

- [ ] **Step 2: Verify**

```bash
# .git must be absent
ls ~/.local/share/chezmoi/dot_config/nvim/.git 2>/dev/null && echo "ERROR: .git present" || echo "OK"
# init.lua must be present
ls ~/.local/share/chezmoi/dot_config/nvim/init.lua
```

- [ ] **Step 3: Commit**

```bash
cd ~/.local/share/chezmoi
git add dot_config/nvim/
git commit -m "feat: add nvim config"
```

---

## Task 4: Add wezterm config

- [ ] **Step 1: Sync wezterm config (including backdrops), excluding .git**

```bash
rsync -a --exclude='.git/' ~/.config/wezterm/ ~/.local/share/chezmoi/dot_config/wezterm/
```

- [ ] **Step 2: Verify**

```bash
ls ~/.local/share/chezmoi/dot_config/wezterm/.git 2>/dev/null && echo "ERROR: .git present" || echo "OK"
# Backdrop count should match
echo "Source: $(ls ~/.config/wezterm/backdrops/ | wc -l) Repo: $(ls ~/.local/share/chezmoi/dot_config/wezterm/backdrops/ | wc -l)"
```

- [ ] **Step 3: Commit**

```bash
cd ~/.local/share/chezmoi
git add dot_config/wezterm/
git commit -m "feat: add wezterm config with backdrops"
```

---

## Task 5: Add zellij config — and fix hardcoded paths

The zellij config contains hardcoded `/Users/dave/` paths in plugin locations:
- `config.kdl`: `zjstatus-hints.wasm` and `zellij-attention.wasm` references
- `layouts/default.kdl` and `layouts/dev.kdl`: `zjstatus.wasm` reference

These must be changed to use `~` before committing, otherwise the config will break on any machine where the username isn't `dave`.

- [ ] **Step 1: Sync zellij config into chezmoi source, excluding .git**

```bash
rsync -a --exclude='.git/' ~/.config/zellij/ ~/.local/share/chezmoi/dot_config/zellij/
```

- [ ] **Step 2: Fix hardcoded paths in the copied files**

```bash
# Replace all /Users/dave with ~ in the zellij config files
sed -i '' 's|file:/Users/dave/|file:~/|g' \
  ~/.local/share/chezmoi/dot_config/zellij/config.kdl \
  ~/.local/share/chezmoi/dot_config/zellij/layouts/default.kdl \
  ~/.local/share/chezmoi/dot_config/zellij/layouts/dev.kdl
```

- [ ] **Step 3: Verify the substitution**

```bash
grep -n "Users/dave" ~/.local/share/chezmoi/dot_config/zellij/config.kdl \
  ~/.local/share/chezmoi/dot_config/zellij/layouts/default.kdl \
  ~/.local/share/chezmoi/dot_config/zellij/layouts/dev.kdl
```

Expected: no matches

```bash
grep -n 'file:~/' ~/.local/share/chezmoi/dot_config/zellij/config.kdl \
  ~/.local/share/chezmoi/dot_config/zellij/layouts/dev.kdl
```

Expected: lines with `file:~/.config/zellij/plugins/...`

- [ ] **Step 4: Verify .git absent, wasm excluded**

```bash
ls ~/.local/share/chezmoi/dot_config/zellij/.git 2>/dev/null && echo "ERROR: .git present" || echo "OK"
ls ~/.local/share/chezmoi/dot_config/zellij/plugins/*.wasm 2>/dev/null && echo "wasm present in source (will be gitignored)" || echo "no wasm"
git -C ~/.local/share/chezmoi status dot_config/zellij/plugins/ 2>/dev/null
```

Expected: wasm files are present on disk but not tracked by git (gitignored)

- [ ] **Step 5: Commit**

```bash
cd ~/.local/share/chezmoi
git add dot_config/zellij/
git commit -m "feat: add zellij config, replace hardcoded paths with ~"
```

---

## Task 6: Add starship config

- [ ] **Step 1: Copy starship config**

```bash
cp ~/.config/starship.toml ~/.local/share/chezmoi/dot_config/starship.toml
```

- [ ] **Step 2: Commit**

```bash
cd ~/.local/share/chezmoi
git add dot_config/starship.toml
git commit -m "feat: add starship config"
```

---

## Task 7: Add Claude Code settings

`~/.claude/settings.json` contains the zellij hook wiring — it's what makes Claude Code send ⏳/✅ notifications to zellij tabs. It belongs in the repo.

- [ ] **Step 1: Copy Claude Code settings**

```bash
mkdir -p ~/.local/share/chezmoi/dot_claude
cp ~/.claude/settings.json ~/.local/share/chezmoi/dot_claude/settings.json
```

- [ ] **Step 2: Verify no secrets present**

```bash
cat ~/.local/share/chezmoi/dot_claude/settings.json
```

Confirm: only hook config present, no API keys or project-specific data.

- [ ] **Step 3: Commit**

```bash
cd ~/.local/share/chezmoi
git add dot_claude/
git commit -m "feat: add claude code settings (zellij hook wiring)"
```

---

## Task 8: Clean up and add .zshrc

Apply these changes to the copy in the chezmoi source. Do **not** edit `~/.zshrc` directly — that happens in Task 14 when chezmoi apply replaces it with a symlink.

| # | Change |
|---|--------|
| 1 | Delete: `[ -s "/Users/davekavanagh/.bun/_bun" ] && source "/Users/davekavanagh/.bun/_bun"` |
| 2 | Delete: `source ~/bin/functions.sh` (or `/Users/dave/bin/functions.sh`) |
| 3 | Delete: Fig post block — `[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && ...` |
| 4 | Guard: wrap `source /opt/homebrew/share/zsh-syntax-highlighting/...` with `[[ -f ... ]] &&` |
| 5 | Guard: wrap `prompts` PATH line with `[[ -d /Users/dave/Code/prompts/bin ]] &&` |
| 6 | Guard: wrap `prompts` completions source with `[[ -f ... ]] &&` |
| 7 | Verify: `$HOME/bin` is already in PATH (it is — present on line 191); if not, add `export PATH="$HOME/bin:$PATH"` |
| 8 | Add `ap` AWS completion (guarded), replacing what functions.sh provided |

- [ ] **Step 1: Copy .zshrc to chezmoi source**

```bash
cp ~/.zshrc ~/.local/share/chezmoi/dot_zshrc
```

- [ ] **Step 2: Apply all 8 changes to `~/.local/share/chezmoi/dot_zshrc`**

For change 8, add this block after the `aws_profile()` function:

```zsh
# ap: switch AWS profile (tab-completion)
if [[ -n ${ZSH_VERSION-} ]] && command -v aws &>/dev/null; then
    autoload -U +X compinit && compinit
    _ap() {
        local AWS_CONFIG="${HOME}/.aws/config"
        if (( CURRENT == 1 )) && [ -f "${AWS_CONFIG}" ]; then
            local profiles=($(aws configure list-profiles 2>/dev/null | grep -v default))
            _arguments "1: :(${profiles})" "--help[Show help message]"
        fi
    }
    compdef _ap ap
fi
```

- [ ] **Step 3: Verify no sensitive/hardcoded content remains**

```bash
grep -n "davekavanagh\|/Users/dave/bin/functions\|\.fig\|/Users/dave/Code/prompts" \
  ~/.local/share/chezmoi/dot_zshrc
```

Expected: no matches for the first three. The prompts lines should be present but guarded.

- [ ] **Step 4: Commit**

```bash
cd ~/.local/share/chezmoi
git add dot_zshrc
git commit -m "feat: add zshrc (remove fig/bun hardcode, guard prompts, inline ap completion)"
```

---

## Task 9: Add .gitconfig

- [ ] **Step 1: Copy .gitconfig to chezmoi source**

```bash
cp ~/.gitconfig ~/.local/share/chezmoi/dot_gitconfig
```

- [ ] **Step 2: Remove the `attributesfile` line**

`~/.gitattributes` does not exist. Remove the stale reference:

```bash
grep -n "attributesfile" ~/.local/share/chezmoi/dot_gitconfig
```

Delete the line: `attributesfile = /Users/dave/.gitattributes`

Also check for and remove any duplicate `[alias]` sections (the gitconfig has three `[alias]` headers):

```bash
grep -n "^\[alias\]" ~/.local/share/chezmoi/dot_gitconfig
```

Merge all alias entries under a single `[alias]` block.

- [ ] **Step 3: Commit**

```bash
cd ~/.local/share/chezmoi
git add dot_gitconfig
git commit -m "feat: add gitconfig (remove stale attributesfile, deduplicate alias sections)"
```

---

## Task 10: Add .gitignore

- [ ] **Step 1: Copy .gitignore**

```bash
cp ~/.gitignore ~/.local/share/chezmoi/dot_gitignore
```

- [ ] **Step 2: Commit**

```bash
cd ~/.local/share/chezmoi
git add dot_gitignore
git commit -m "feat: add gitignore"
```

---

## Task 11: Generate and add Brewfile

- [ ] **Step 1: Generate Brewfile from current system state**

```bash
brew bundle dump --file=~/.local/share/chezmoi/Brewfile --force
```

- [ ] **Step 2: Verify**

```bash
wc -l ~/.local/share/chezmoi/Brewfile
grep "wezterm\|zellij\|neovim\|starship\|chezmoi" ~/.local/share/chezmoi/Brewfile
```

- [ ] **Step 3: Commit**

```bash
cd ~/.local/share/chezmoi
git add Brewfile
git commit -m "feat: add Brewfile generated from current system state"
```

---

## Task 12: Find the zellij-attention plugin source URL

The `zellij-attention.wasm` plugin provides Claude Code tab notifications (⏳/✅). Before writing install.sh, find its download URL.

- [ ] **Step 1: Check git log for when it was added**

```bash
git -C ~/.config/zellij log --all -p -- plugins/zellij-attention.wasm 2>/dev/null | head -30
```

Look for a download URL in the commit diff or message.

- [ ] **Step 2: If not in git log, search GitHub**

Search GitHub for `zellij-attention` — look for a repo that produces a `zellij-attention.wasm` release binary. Candidate: check Claude Code's community resources or https://github.com/rvcas/zellij-switch-mode and related repos.

- [ ] **Step 3: Record the confirmed URL**

Note the URL here before proceeding to Task 13. It will be used in install.sh as:
```
download_wasm "zellij-attention.wasm" "<URL>"
```

---

## Task 13: Write install.sh

- [ ] **Step 1: Write install.sh** (substituting the confirmed zellij-attention URL from Task 12)

```bash
cat > ~/.local/share/chezmoi/install.sh << 'INSTALLEOF'
#!/usr/bin/env bash
set -euo pipefail

# Dotfiles bootstrap — macOS only, idempotent (safe to re-run)
# Prerequisites: SSH key configured and added to GitHub
# Usage: ./install.sh
#        curl -fsSL https://raw.githubusercontent.com/dave-kav/dotfiles/main/install.sh | bash

CHEZMOI_SOURCE="${HOME}/.local/share/chezmoi"

step() { echo ""; echo "==> $1"; }
ok()   { echo "    ✓ $1"; }
skip() { echo "    → $1 (skipping)"; }

# ── 1. Xcode CLI Tools ────────────────────────────────────────────────────────

step "Xcode CLI Tools"
if xcode-select -p &>/dev/null; then
  skip "already installed"
else
  softwareupdate --install -a
  ok "installed"
fi

# ── 2. Homebrew ───────────────────────────────────────────────────────────────

step "Homebrew"
if command -v brew &>/dev/null; then
  skip "already installed at $(which brew)"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
  ok "installed"
fi

# ── 3. chezmoi ────────────────────────────────────────────────────────────────

step "chezmoi"
if command -v chezmoi &>/dev/null; then
  skip "already installed"
else
  brew install chezmoi
  ok "installed"
fi

# ── 4. Apply dotfiles ─────────────────────────────────────────────────────────

step "Dotfiles (chezmoi)"
if [[ -d "${CHEZMOI_SOURCE}/.git" ]]; then
  echo "    chezmoi source already exists — applying"
  chezmoi apply
  ok "applied"
else
  # Use HTTPS for initial clone — SSH key may not be set up yet on fresh machine
  chezmoi init --apply dave-kav/dotfiles
  ok "initialised and applied"
fi

# ── 5. Brew bundle ────────────────────────────────────────────────────────────

step "Brew bundle"
brew bundle --file="${CHEZMOI_SOURCE}/Brewfile" --no-lock
ok "done"

# ── 6. oh-my-zsh ─────────────────────────────────────────────────────────────

step "oh-my-zsh"
if [[ -d "${HOME}/.oh-my-zsh" ]]; then
  skip "already installed"
else
  RUNZSH=no CHSH=no \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ok "installed"
fi

# ── 7. alias-tips plugin ──────────────────────────────────────────────────────

step "alias-tips oh-my-zsh plugin"
ALIAS_TIPS_DIR="${HOME}/.oh-my-zsh/custom/plugins/alias-tips"
if [[ -d "${ALIAS_TIPS_DIR}" ]]; then
  skip "already present"
else
  git clone https://github.com/djui/alias-tips.git "${ALIAS_TIPS_DIR}"
  ok "cloned"
fi

# ── 8. Zellij wasm plugins ────────────────────────────────────────────────────

step "Zellij wasm plugins"
PLUGINS_DIR="${HOME}/.config/zellij/plugins"
mkdir -p "${PLUGINS_DIR}"

download_wasm() {
  local name="$1" url="$2"
  if [[ -f "${PLUGINS_DIR}/${name}" ]]; then
    skip "${name} already present"
  else
    echo "    Downloading ${name}..."
    curl -fsSL "${url}" -o "${PLUGINS_DIR}/${name}"
    ok "${name}"
  fi
}

# To upgrade: delete the .wasm file and re-run this script
download_wasm "zjstatus.wasm" \
  "https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm"
download_wasm "zjstatus-hints.wasm" \
  "https://github.com/dj95/zjstatus/releases/latest/download/zjstatus-hints.wasm"
download_wasm "zellij-attention.wasm" \
  "REPLACE_WITH_CONFIRMED_URL_FROM_TASK_12"

# ── 9. Font cache flush ───────────────────────────────────────────────────────

step "Font cache"
if sudo atsutil server -shutdown 2>/dev/null; then
  ok "cache flushed"
else
  ok "skipped (no sudo or not needed)"
fi

# ── 10. Manual steps reminder ─────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════════════════"
echo "  ✅  Bootstrap complete. Manual steps remaining:"
echo "════════════════════════════════════════════════════"
echo ""
echo "  1. Restart terminal (new .zshrc takes effect)"
echo ""
echo "  2. GPG key (required for git commit signing):"
echo "       gpg --import <your-key-backup.gpg>"
echo "       # Verify key 9F21127EA36DD888 is present:"
echo "       gpg --list-secret-keys"
echo ""
echo "  3. SSH key (if not already set up):"
echo "       ssh-keygen -t ed25519 -C 'your@email.com'"
echo "       gh ssh-key add ~/.ssh/id_ed25519.pub"
echo ""
echo "  4. Default shell (if zsh is not already default):"
echo "       chsh -s \$(which zsh)"
echo ""
echo "  5. Shell history sync (when ready):"
echo "       atuin register  # or: atuin login"
echo "       atuin sync"
echo ""
INSTALLEOF

chmod +x ~/.local/share/chezmoi/install.sh
```

- [ ] **Step 2: Replace the zellij-attention placeholder with the URL found in Task 12**

```bash
# Edit install.sh and replace REPLACE_WITH_CONFIRMED_URL_FROM_TASK_12
# with the actual URL
```

- [ ] **Step 3: Verify the script is valid shell syntax**

```bash
bash -n ~/.local/share/chezmoi/install.sh && echo "Syntax OK"
```

Expected: `Syntax OK`

- [ ] **Step 4: Commit**

```bash
cd ~/.local/share/chezmoi
git add install.sh
git commit -m "feat: add bootstrap install.sh"
```

---

## Task 14: Write README

- [ ] **Step 1: Write README.md**

```bash
cat > ~/.local/share/chezmoi/README.md << 'EOF'
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

> Prerequisites: SSH key configured and added to GitHub.

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
- zellij-attention — Claude Code tab notifications (⏳/✅)

To upgrade: delete the `.wasm` files from `~/.config/zellij/plugins/` and re-run `install.sh`.

## Shell history

Managed locally via [atuin](https://atuin.sh). To sync across machines:

```bash
atuin register  # or: atuin login
atuin sync
```

History is end-to-end encrypted.
EOF
```

- [ ] **Step 2: Commit**

```bash
cd ~/.local/share/chezmoi
git add README.md
git commit -m "docs: add README"
```

---

## Task 15: Apply chezmoi — migrate from real dirs to symlinks

This replaces `~/.config/nvim`, `~/.config/wezterm`, `~/.config/zellij`, `~/.config/starship.toml`, `~/.zshrc`, `~/.gitconfig`, `~/.gitignore`, and `~/.claude/settings.json` with symlinks into `~/.local/share/chezmoi/`.

> ⚠️ Back up first. The existing configs will be removed and replaced by symlinks.

- [ ] **Step 1: Back up existing config dirs**

```bash
cp -r ~/.config/nvim    ~/nvim_backup
cp -r ~/.config/wezterm ~/wezterm_backup
cp -r ~/.config/zellij  ~/zellij_backup
cp    ~/.zshrc           ~/zshrc_backup
echo "Backups done"
```

- [ ] **Step 2: Remove existing dirs so chezmoi can create symlinks**

```bash
rm -rf ~/.config/nvim
rm -rf ~/.config/wezterm
rm -rf ~/.config/zellij
rm -f  ~/.config/starship.toml
```

Note: `.zshrc`, `.gitconfig`, `.gitignore`, and `~/.claude/settings.json` are files — chezmoi apply will replace them with symlinks automatically (no need to pre-delete).

- [ ] **Step 3: Apply chezmoi**

```bash
chezmoi apply
```

- [ ] **Step 4: Verify symlinks**

```bash
ls -la ~/.config/nvim ~/.config/wezterm ~/.config/zellij ~/.config/starship.toml
ls -la ~/.zshrc ~/.gitconfig ~/.gitignore ~/.claude/settings.json
```

All should show as `->` symlinks pointing into `~/.local/share/chezmoi/`.

- [ ] **Step 5: Verify zellij plugin paths resolved correctly**

```bash
grep "file:~/" ~/.config/zellij/config.kdl ~/.config/zellij/layouts/dev.kdl
```

Expected: paths using `~/` not `/Users/dave/`

- [ ] **Step 6: Verify wasm files are still present (not managed by chezmoi, but still needed)**

```bash
ls ~/.config/zellij/plugins/*.wasm
```

Expected: all three wasm files present. Note: these are inside the symlinked directory, coming from the chezmoi source copy. They were excluded from git tracking but the files themselves are present on disk.

- [ ] **Step 7: Smoke test: open nvim**

```bash
nvim --version
nvim -c "lua print('ok')" -c "q"
```

- [ ] **Step 8: Verify chezmoi is clean**

```bash
chezmoi verify
```

Expected: no output (source and destinations match)

- [ ] **Step 9: Clean up backups once satisfied**

```bash
rm -rf ~/nvim_backup ~/wezterm_backup ~/zellij_backup ~/zshrc_backup
```

---

## Task 16: Push and validate

- [ ] **Step 1: Push to GitHub**

```bash
cd ~/.local/share/chezmoi
git push -u origin main
```

- [ ] **Step 2: Verify the repo looks correct on GitHub**

```bash
gh repo view dave-kav/dotfiles --web
```

- [ ] **Step 3: Verify install.sh is accessible via the curl URL**

```bash
curl -fsSL https://raw.githubusercontent.com/dave-kav/dotfiles/main/install.sh | head -5
```

Expected: first lines of the install script

---

## Task 17: Archive old repos and move spec

- [ ] **Step 1: Update old wezterm-config README to redirect**

```bash
gh repo clone dave-kav/wezterm-config /tmp/wezterm-config-old
cat > /tmp/wezterm-config-old/README.md << 'EOF'
# ⚠️ Archived

This repo has been merged into [dave-kav/dotfiles](https://github.com/dave-kav/dotfiles).
EOF
cd /tmp/wezterm-config-old
git add README.md
git commit -m "chore: archive — merged into dave-kav/dotfiles"
git push
```

- [ ] **Step 2: Archive on GitHub**

```bash
gh repo archive dave-kav/wezterm-config --yes
rm -rf /tmp/wezterm-config-old
```

- [ ] **Step 3: Move the spec and plan docs into the dotfiles repo**

```bash
mkdir -p ~/.local/share/chezmoi/docs/superpowers/specs
mkdir -p ~/.local/share/chezmoi/docs/superpowers/plans
cp ~/.config/nvim/docs/superpowers/specs/2026-04-13-dotfiles-design.md \
   ~/.local/share/chezmoi/docs/superpowers/specs/
cp ~/.config/nvim/docs/superpowers/plans/2026-04-13-dotfiles-monorepo.md \
   ~/.local/share/chezmoi/docs/superpowers/plans/
cd ~/.local/share/chezmoi
git add docs/
git commit -m "docs: add design spec and implementation plan"
git push
```

---

## Final checklist

- [ ] `chezmoi verify` returns clean
- [ ] `ls -la ~/.config/nvim` shows a symlink into chezmoi source
- [ ] `nvim` launches correctly
- [ ] WezTerm backdrops work (`Cmd+/` in WezTerm)
- [ ] Zellij dev layout works (`Cmd+Ctrl+p` → pick a project)
- [ ] No `/Users/dave` hardcoded paths in committed zellij configs
- [ ] `cat ~/.zshrc` shows cleaned-up version (no Fig block, no davekavanagh)
- [ ] `bash -n install.sh` passes
- [ ] zellij-attention URL placeholder replaced with real URL
- [ ] Old `wezterm-config` repo archived on GitHub
