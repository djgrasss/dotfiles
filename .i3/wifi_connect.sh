#!/bin/bash

#ap=$(nmcli dev wifi | tail -n +2| awk -F"'" '{print $2}' | dmenu -i)
aps=$(nmcli dev wifi | tail -n +2| awk -F"'" '{print $2}')
i=1
IFS=$'\n'
for n in $aps; do
  apv[i]=$n
  i=$((i+1))
done
ap=$(/usr/bin/zenity --entry --title "Available AP" --text "Choose AP to join" --entry-text "${apv[@]}")
[ -z "$ap" ] && exit 1

found=$(nmcli con list | awk -v pattern="$ap" '$0 ~ pattern {print "found"}')
if [ -n "$found" ]; then
 nmcli con up id "$ap"
else
  pass=$(/usr/bin/zenity --password --title "AP password:" --text "Enter AP password:")
  [ -n "$pass" ] && {
#gksu -- nmcli dev wifi connect "$ap" password "$pass" --private
    nmcli dev wifi connect "$ap" password "$pass" --private
  }
fi

