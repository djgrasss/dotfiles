#!/bin/bash

#ap=$(nmcli dev wifi | tail -n +2| awk -F"'" '{print $2}' | dmenu -i)
aps=$(/usr/bin/nmcli dev wifi | tail -n +2| /usr/bin/awk -F"'" '{print $2}')
i=1
IFS=$'\n'
for n in $aps; do
  apv[i]=$n
  i=$((i+1))
done
ap=$(/usr/bin/zenity --entry --title "Available AP" --text "Choose AP to join" --entry-text "${apv[@]}")
[ -z "$ap" ] && exit 1

found=$(/usr/bin/nmcli con list | /usr/bin/awk -v pattern="$ap" '$0 ~ pattern {print "found"}')
if [ -n "$found" ]; then
 /usr/bin/nmcli con up id "$ap"
else
  pass=$(/usr/bin/zenity --password --title "AP password:" --text "Enter AP password:")
  [ -n "$pass" ] && {
#gksu -- nmcli dev wifi connect "$ap" password "$pass" --private
    /usr/bin/nmcli dev wifi connect "$ap" password "$pass" --private
  }
fi

