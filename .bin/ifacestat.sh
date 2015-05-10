#!/bin/sh

ec='echo -e';[ -n "$($ec)" ] && ec='echo'

f="/sys/class/net/${1:-wlan0}/statistics/"
while [ -w /proc/self/fd/1 ]; do
  tx=$(cat "$f/tx_bytes")
  rx=$(cat "$f/rx_bytes")
  c=$((tx+rx))
  s="$(((c-${oc:-c})))"
  [ $s -ge 0 ] && {
    [ -t 1 ] && ($ec -n "\033[s$s ${2+$((tx-${otx:-tx}))} ${2+$((rx-${orx:-rx}))}\033[K\033[u")
    [ ! -t 1 ] && echo "$s ${2+$((tx-${otx:-tx}))} ${2+$((rx-${orx:-rx}))}" 
  }
  oc=$c
  otx=$tx
  orx=$rx
  sleep 1
done

