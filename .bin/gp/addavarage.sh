#!/bin/bash

avs=${1:-10}     # avarage over so many last samples, default is 10 
column=${2:-1}   # read new value from this column
sum=0

while read newLine; do
  newVal="$(echo $newLine|awk -v col=$column '{print $col}')"
  [ -n "$newVal" ] && {
    [ "${#a[@]}" -ge $avs ] && {
      sum=$((sum - ${a[0]}))
      a=(${a[@]:1}) # pop from the front
    }
    a=("${a[@]}" "$newVal") # add to the end
    sum=$((sum + newVal))
    if [ -t 1 ]; then
      echo -ne "\033[s$newLine $((sum/avs))\033[K\033[u"
    else
      echo "$newLine $((sum/avs))"
    fi
  }
done

