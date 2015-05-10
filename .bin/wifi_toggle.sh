#!/bin/bash

wifistat=$(nmcli nm wifi)
if [ "disabled" = ${wifistat#*\ } ]; then
  nmcli nm wifi on
  wifistat=$(nmcli nm wifi)
  notify-send -u low -i /usr/share/icons/elementary-xfce/status/48/wifi-100.png "WiFi status:" "WiFi is now ${wifistat#*\ }"
else
  nmcli nm wifi off
  wifistat=$(nmcli nm wifi)
  notify-send -u low -i /usr/share/icons/elementary-xfce/status/48/wifi-100.png "WiFi status:" "WiFi is now ${wifistat#*\ }"
fi

