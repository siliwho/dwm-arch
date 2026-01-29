
#!/usr/bin/env bash

# -------------------------------------------------
# Paths
# -------------------------------------------------
DWM_DIR="$HOME/.config/dwm"
THEME_DIR="$DWM_DIR/themes"
THEME_H="$DWM_DIR/theme.h"

WALLPAPER_DIR="$HOME/Pictures/wallpapers/theme"
INDEX_FILE="$HOME/.cache/theme-wallpaper-index"
CURRENT_THEME="$HOME/.cache/dwm-current-theme"

KITTY_THEME_DIR="$HOME/.config/kitty/themes"
ALACRITTY_THEME_DIR="$HOME/.config/alacritty/themes"

mkdir -p "$(dirname "$INDEX_FILE")"

# -------------------------------------------------
# Wallpaper rotation
# -------------------------------------------------
get_next_wallpaper() {
    local theme="$1"
    local files=() idx max

    while IFS= read -r -d '' f; do
        files+=("$f")
    done < <(
        find "$WALLPAPER_DIR" -type f \
            -regex ".*/${theme}-[0-9]+\.\(jpg\|png\)" \
            -print0 | sort -z -V
    )

    max=${#files[@]}
    (( max == 0 )) && return

    idx=$(grep "^$theme=" "$INDEX_FILE" 2>/dev/null | cut -d= -f2)
    [[ -z "$idx" ]] && idx=0
    idx=$(( (idx % max) + 1 ))

    sed -i "/^$theme=/d" "$INDEX_FILE"
    echo "$theme=$idx" >> "$INDEX_FILE"

    echo "${files[$((idx - 1))]}"
}

# -------------------------------------------------
# Xresources (for bar / other tools)
# -------------------------------------------------
apply_xresources() {
    xrdb -merge <<EOF
dwm.bg: $(grep col_cyan  "$THEME_H" | awk '{print $NF}' | tr -d '";')
dwm.fg: $(grep col_gray3 "$THEME_H" | awk '{print $NF}' | tr -d '";')
EOF
}

# -------------------------------------------------
# Apply theme
# -------------------------------------------------
apply_theme() {
    local theme="$1"
    local src="$THEME_DIR/$theme.h"

    if [[ ! -f "$src" ]]; then
        notify-send "❌ Theme not found: $theme"
        exit 1
    fi

    # remember current theme
    echo "$theme" > "$CURRENT_THEME"

    # dwm colors
    cp "$src" "$THEME_H"
    apply_xresources

    # wallpaper (nitrogen)
    wp="$(get_next_wallpaper "$theme")"
    if [[ -n "$wp" ]]; then
        nitrogen --set-zoom-fill "$wp" --save
    fi

    # rebuild + restart dwm (sudo KEPT as requested)
    cd "$DWM_DIR" || exit 1
    sudo make clean install
    pkill -HUP dwm

    # -------------------------------------------------
    # Kitty theme (live reload)
    # -------------------------------------------------
    if [[ -f "$KITTY_THEME_DIR/$theme.conf" ]]; then
        ln -sf "$KITTY_THEME_DIR/$theme.conf" "$KITTY_THEME_DIR/current.conf"
        kitty @ set-colors --all "$KITTY_THEME_DIR/current.conf" 2>/dev/null
    fi

    # -------------------------------------------------
    # Alacritty theme (new windows / reload if supported)
    # -------------------------------------------------
    if [[ -f "$ALACRITTY_THEME_DIR/$theme.toml" ]]; then
        ln -sf "$ALACRITTY_THEME_DIR/$theme.toml" "$ALACRITTY_THEME_DIR/current.toml"
        pkill -USR1 alacritty 2>/dev/null
    fi

    notify-send "🎨 Theme switched to $theme"
}

# -------------------------------------------------
# Entry point
# -------------------------------------------------
apply_theme "$1"

