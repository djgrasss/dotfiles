#!/bin/sh

ec='echo -e';[ -n "$($ec)" ] && ec='echo'

while [ -w /proc/self/fd/1 ]; do
  res=$(sed -nr 's/^cpu (.*)/\1/p' /proc/stat|awk '{for(i=1;i<=NF;++i){s+=$i}printf "%s %s\n",s,$4+$5}')
  total=${res%% *}
  idle=${res#* }
  [ -n "$prevtotal" ] && {
    s=$(((100*(total-prevtotal-idle+previdle))/(total-prevtotal)))
    [ -t 1 ] && ($ec -n "\033[s$s\033[K\033[u")
    [ ! -t 1 ] && echo "$s" 
  }

  prevtotal=$total
  previdle=$idle
  sleep 1
done

