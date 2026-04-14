#!/bin/bash
# Remove broken symlinks from the WezTerm backdrops directory after every apply
find "$HOME/.config/wezterm/backdrops" -type l | while read -r link; do
  target=$(readlink "$link")
  if [ ! -f "$target" ]; then
    rm -f "$link"
  fi
done
