#!/bin/bash

IFS=$'\n'
nmout=$(nmcli -m multiline -t -f ssid,bssid,freq,signal,security dev wifi)
aps=$(echo "$nmout" | awk 'BEGIN{cnt=0}\
                           {if(/^SSID/){ssid=gensub(/^SSID:.(.*)./,"\\1","g")};\
                            if(/^BSSID/){bssid=gensub(/^BSSID:(.*)/,"\\1","g")};\
                            if(/^FREQ/){freq=gensub(/^FREQ:(.*)/,"\\1","g")};\
                            if(/^SIGNAL/){signal=gensub(/^SIGNAL:(.*)/,"\\1","g")};\
                            if(/^SECURITY/){sec=gensub(/^SECURITY:(.*)/,"\\1","g");if(length(sec)==0){sec="--"}};\
                            cnt++;if(cnt>4){cnt=0;print ssid" ["bssid"] ["freq"] ["sec"] ["signal"]"}}'|sort -nr -t[ -k5|uniq)
i=1
ifacecon=$(nmcli dev status | awk '$2 ~ "wireless" && $3 == "connected" {printf("disconnect [%s]\n",$1)}')
for n in $ifacecon; do
  apv[i]=$n
  i=$((i+1))
done
for n in $aps; do
  apv[i]=$n
  i=$((i+1))
done
ap=$(/usr/bin/yad --entry --title "Available AP" --text "Choose AP to join" --entry-text "${apv[@]}")
[ -z "$ap" ] && exit 1
# is that a disconnection request?
for n in $ifacecon; do
  [ "$n" = "$ap" ] && {
    ap_bssid=$(echo "$ap"|sed -nr 's/[^[]*.([^]]*).*/\1/p')
    nmcli dev disconnect iface "${ap_bssid#* }"
    exit 0
  }
done
# I cannot grep for '[' char to get ap name and ap bssid
# because ap name could contain that char so I use awk again
ap_tuple=$(echo "$nmout"|awk -v ap="$ap" '{bssid=gensub(/^BSSID:(.*)/,"\\1","g");\
                                          if(flag==1){printf("%s\n%s\n",ssid,bssid);exit}\
                                          else{ssid=gensub(/^SSID:.(.*)./,"\\1","g");if(ap ~ ssid){flag=1}}}')
ap_name=${ap_tuple%$'\n'*}
ap_bssid=${ap_tuple#*$'\n'}
found=$(nmcli con list id "$ap_name" 2>/dev/null|awk -v bssid="$ap_bssid" '$0 ~ /seen-bssids/{if (1==index($2,bssid)){print "found"}}')
if [ -n "$found" ]; then
  /usr/bin/nmcli con up id "$ap_name"
else
  secur=$(nmcli dev wifi | grep "$ap_bssid" | awk -F'MB/s' '{print $2}' | awk '{print $2}')
  if [ "$secur" != "--" ]; then
    pass=$(/usr/bin/yad --image='dialog-password' --image='dialog-password' --entry --title "AP password:" --text "Enter AP password:" --hide-text)
    [ -n "$pass" ] && {
      /usr/bin/nmcli dev wifi connect "$ap_bssid" password "$pass" --private
    }
  else
    /usr/bin/nmcli dev wifi connect "$ap_bssid" --private
  fi
fi

