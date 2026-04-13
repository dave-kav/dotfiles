#!/usr/bin/env bash
set -euo pipefail

# Dotfiles bootstrap — macOS only, idempotent (safe to re-run)
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
  "https://github.com/KiryuuLight/zellij-attention/releases/latest/download/zellij-attention.wasm"

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
