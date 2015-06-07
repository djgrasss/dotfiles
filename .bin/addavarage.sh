#!/bin/bash

avs=${1:-10}     # avarage over so many last samples, default is 10 
sum=0

while read newLine; do
  [ -n "$newLine" ] && {
    [ "${#a[@]}" -ge $avs ] && {
      sum=$((sum - ${a[0]}))
      a=(${a[@]:1}) # pop from the front
    }
    a=("${a[@]}" "$newLine") # add to the end
    sum=$((sum + newLine))
    echo "$newLine $((sum/avs))"
  }
done

