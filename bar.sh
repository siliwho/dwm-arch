#!/bin/bash

background="#5884d4" 
foreground="#0E1113"

battery(){
  cmd="$(acpi | cut -d, -f2 | awk '{print $1}' | cut -d% -f1)"
  echo -ne "^b$background^^c$foreground^ BATTERY ^d^ $cmd%"
}

# volume(){
#   volume="$(pactl get-sink-volume 0 | cut -d/ -f2 | sed -n 1p | awk '{print $1}' | cut -d% -f1)"
#   volume1="$(pactl get-sink-mute 0 | cut -d: -f2 | awk '{print $1}')"
#   if [ "$volume1" == "yes" ]; then
# 	  echo -ne "^b$background^^c$foreground^ VOLUME ^d^ MUTE"
#   else
# 	  echo -ne "^b$background^^c$foreground^ VOLUME ^d^ $volume%"
#   fi
# }

volume(){
  volume1="$(pactl get-sink-mute @DEFAULT_SINK@ | cut -d: -f2 | awk '{print $1}')"
  if [ "$volume1" == "yes" ]; then
    echo -ne "^b$background^^c$foreground^ VOLUME ^d^ MUTE"
  else
    volume2="$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1)"
    echo -ne "^b$background^^c$foreground^ VOLUME ^d^ $volume2"
  fi
}


brightness(){
  cmd="$(sudo ybacklight -get | cut -d. -f1)"
  echo -ne "^b$background^^c$foreground^ BRIGHTNESS ^d^ $cmd%"
}

mute(){
  cmd="$(pactl get-sink-mute @DEFAULT_SINK@ | cut -d: -f2 | awk '{print $1}')"
  echo -ne "^b$background^^c$foreground^ MUTE ^d^ $cmd"
}

bluetooth(){
	cmd="$(bluetoothctl devices Connected | sed -n 1p)"
  if [ "$cmd" != "" ]; then
    echo -ne "^b$background^^c$foreground^ BLUETOOTH ^d^ $cmd"
  fi
}

wifi(){
	cmd="$(nmcli connection | awk '{print $1}' | sed -n 2p)"
  echo -ne "^b$background^^c$foreground^ WIFI ^d^ $cmd"
}

arch(){
	cmd="󰣇 ARCHLINUX"
  echo -ne "^c$background^ $cmd^d^"
}

_time(){
  cmd="$(date +'%I:%M %p')"
  echo -ne "^b$background^^c$foreground^ TIME ^d^ $cmd"
}

_date(){
  cmd="$(date +'%b %d, %a')"
  echo -ne "^b$background^^c$foreground^ DATE ^d^ $cmd"
}

_mem(){
  mem_used="$(top -b -n 1 | grep -i mem | sed -n 1p | awk '{print $8}')"
  mem_total="$(top -b -n 1 | grep -i mem | sed -n 1p | awk '{print $4}')"
  mem_perc_with_extra="$(echo "scale = 4; ($mem_used/$mem_total)*100" | bc)"
  final_mem_perc="${mem_perc_with_extra::-2}%"
  echo -ne "^b$background^^c$foreground^ MEM ^d^ $final_mem_perc"
}

_cpu(){
  foo="$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}')"
  cmd=${foo::-2}
  cmd="$(echo $cmd | cut -c 1-4)%"
  echo -ne "^b$background^^c$foreground^ CPU ^d^ $cmd"
}

while true; do

    sleep 1 && xsetroot -name "$(arch) $(_cpu) $(_mem) $(volume) $(battery) $(_time) $(_date) "
done &
