
#!/usr/bin/env bash

THEME_FILE="$HOME/.cache/dwm-current-theme"
THEME_DIR="$HOME/.config/dwm/bar-themes"
WALLPAPER_DIR="$HOME/Pictures/wallpapers/theme"
INDEX_FILE="$HOME/.cache/theme-wallpaper-index"

# ---------- load theme ----------
theme="tokyo"  # fallback
[ -f "$THEME_FILE" ] && theme="$(cat "$THEME_FILE")"

theme_colors="$THEME_DIR/$theme.colors"
[ -f "$theme_colors" ] && source "$theme_colors"

# final fallbacks
BG="${BG:-#5884d4}"
FG="${FG:-#0E1113}"

# ---------- set wallpaper ONCE ----------
set_wallpaper() {
    files=()
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
    [[ -z "$idx" ]] && idx=1

    nitrogen --set-zoom-fill "${files[$((idx - 1))]}" --save
}

set_wallpaper

# ---------- modules ----------
 # arch() { echo -ne "^c$BG^ 󰣇 ^d^"; }
 #
 # cpu() {
 #     u=$(awk '{u=($2+$4)*100/($2+$4+$5)} END {printf "%d", u}' /proc/stat)
 #     echo -ne "^b$BG^^c$FG^ CPU ^d^ $u%"
 # }
 #
 # mem() {
 #     t=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
 #     a=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
 #     echo -ne "^b$BG^^c$FG^ MEM ^d^ $(( (t-a)*100/t ))%"
 # }
 #
 # vol() {
 #     mute=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
 #     if [ "$mute" = "yes" ]; then
 #         echo -ne "^b$BG^^c$FG^ VOL ^d^ MUTE"
 #     else
 #         v=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1)
 #         echo -ne "^b$BG^^c$FG^ VOL ^d^ $v"
 #     fi
 # }
 #
 # bat() {
 #     b=$(acpi -b | grep -oP '\d+%')
 #     echo -ne "^b$BG^^c$FG^ BAT ^d^ $b"
 # }
 #
 # time_() { echo -ne "^b$BG^^c$FG^ TIME ^d^ $(date '+%I:%M %p')"; }
 # date_() { echo -ne "^b$BG^^c$FG^ DATE ^d^ $(date '+%b %d, %a')"; }
 #
 # # ---------- loop ----------
 # while true; do
 #     xsetroot -name "$(arch) $(cpu) $(mem) $(vol) $(bat) $(time_) $(date_)"
 #     sleep 1
 # done &
 #

volume(){
  volume1="$(pactl get-sink-mute @DEFAULT_SINK@ | cut -d: -f2 | awk '{print $1}')"
  if [ "$volume1" == "yes" ]; then
    echo -ne "^b$BG^^c$FG^ VOLUME ^d^ MUTE"
  else
    volume2="$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1)"
    echo -ne "^b$BG^^c$FG^ VOLUME ^d^ $volume2"
  fi
}


brightness(){
  cmd="$(sudo ybacklight -get | cut -d. -f1)"
  echo -ne "^b$BG^^c$FG^ BRIGHTNESS ^d^ $cmd%"
}

mute(){
  cmd="$(pactl get-sink-mute @DEFAULT_SINK@ | cut -d: -f2 | awk '{print $1}')"
  echo -ne "^b$BG^^c$FG^ MUTE ^d^ $cmd"
}

bluetooth(){
	cmd="$(bluetoothctl devices Connected | sed -n 1p)"
  if [ "$cmd" != "" ]; then
    echo -ne "^b$BG^^c$FG^ BLUETOOTH ^d^ $cmd"
  fi
}

wifi(){
	cmd="$(nmcli connection | awk '{print $1}' | sed -n 2p)"
  echo -ne "^b$BG^^c$FG^ WIFI ^d^ $cmd"
}

arch(){
	cmd=" 󰣇 "
  echo -ne "^c$BG^ $cmd^d^"
}

_time(){
  cmd="$(date +'%I:%M %p')"
  echo -ne "^b$BG^^c$FG^ TIME ^d^ $cmd"
}

_date(){
  cmd="$(date +'%b %d, %a')"
  echo -ne "^b$BG^^c$FG^ DATE ^d^ $cmd"
}

battery(){
  cmd=$(acpi -b | grep -oP '\d+%' | tr -d '%')
  echo -ne "^b$BG^^c$FG^ BATTERY ^d^ ${cmd}%"
}

_mem(){
  mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  mem_avail=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
  mem_used=$((mem_total - mem_avail))
  mem_perc=$(( (mem_used * 100) / mem_total ))
  echo -ne "^b$BG^^c$FG^ MEM ^d^ ${mem_perc}%"
}

_cpu(){
  foo="$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}')"
  cmd=${foo::-2}
  cmd="$(echo $cmd | cut -c 1-4)%"
  echo -ne "^b$BG^^c$FG^ CPU ^d^ $cmd"
}

while true; do

    sleep 1 && xsetroot -name "$(arch) $(_cpu) $(_mem) $(volume) $(battery) $(_time) $(_date) "
done &



