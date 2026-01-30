
#!/usr/bin/env bash

THEME="$1"
DIR="$HOME/Pictures/wallpapers/theme"

find "$DIR" -type f \
  -regex ".*/${THEME}-[0-9]+\.\(jpg\|png\)" \
  | sort -V
