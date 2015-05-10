#!/bin/bash

winsize=${1:-60} # number of samples to store
avs=${2:-10}     # avarage over so many last samples (should be less or equal to winsize)
seconds=0        # seconds counter
sum=0

while read newLine; do
  [ -n "$newLine" ] && {
    [ "${#a[@]}" -ge $avs ] && {
      sum=$((sum - ${a[$((${#a[@]}-$avs))]}))
    }
    a=("${a[@]}" "$newLine") # add to the end
    [ "${#a[@]}" -gt $winsize ] && {
      a=(${a[@]:1}) # pop from the front
      s=(${s[@]:1}) # pop from the front
      seconds=$((seconds + 1))
    }
    sum=$((sum + newLine))
    s=("${s[@]}" "$sum") # add to the end
    tc=0
    for i in ${a[@]}; do
      echo "$((seconds+tc)) $i $((s[$tc]/avs))"
      tc=$((tc+1))
    done
    echo e # gnuplot's end of dataset marker
  }
done

