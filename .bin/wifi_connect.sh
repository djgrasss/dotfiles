#!/bin/bash

aps=$(nmcli dev wifi | tail -n +2| /usr/bin/awk -F"'" '{printf("%s (%s)\n", $2, gensub(/^\ *([^\ ]*).*/,"\\1","g",$3))}'|sort|uniq)
i=1
IFS=$'\n'
#IFS=$';'
for n in $aps; do
  apv[i]=$n
  i=$((i+1))
done
ap=$(/usr/bin/zenity --entry --title "Available AP" --text "Choose AP to join" --entry-text "${apv[@]}")
[ -z "$ap" ] && exit 1
ap_name=$(echo "$ap"|sed -nr 's/(.*) \(.*/\1/p')
ap_bssid=$(echo "$ap"|sed -nr 's/[^(]*\(([^)]*).*/\1/p')
found=$(nmcli con list id "$ap_name" 2>/dev/null|awk -v bssid="$ap_bssid" '$0 ~ /seen-bssids/{if (1==index($2,bssid)){print "found"}}')
if [ -n "$found" ]; then
  /usr/bin/nmcli con up id "$ap_name"
else
  secur=$(nmcli dev wifi | grep "$ap_bssid" | awk -F'MB/s' '{print $2}' | awk '{print $2}')
  if [ "$secur" != "--" ]; then
    pass=$(/usr/bin/zenity --password --title "AP password:" --text "Enter AP password:")
    [ -n "$pass" ] && {
      /usr/bin/nmcli dev wifi connect "$ap_bssid" password "$pass" --private
    }
  else
    /usr/bin/nmcli dev wifi connect "$ap_bssid" --private
  fi
fi

