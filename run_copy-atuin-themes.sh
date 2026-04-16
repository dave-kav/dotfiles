#!/bin/bash
# Atuin can't read theme files through symlinks — copy them as real files
THEME_SRC="$HOME/.local/share/chezmoi/dot_config/private_atuin/themes"
THEME_DST="$HOME/.config/atuin/themes"

mkdir -p "$THEME_DST"
for src in "$THEME_SRC"/*.toml; do
  [ -f "$src" ] || continue
  name="$(basename "$src")"
  rm -f "$THEME_DST/$name"
  cp "$src" "$THEME_DST/$name"
done
