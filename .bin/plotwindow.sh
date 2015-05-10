#!/bin/bash

winsize=${1:-60} # number of samples to store
seconds=0  # seconds counter

while read newLine; do
  [ -n "$newLine" ] && {
    newLine=$(echo "$newLine"|awk '{for(i=1;i<NF;++i){printf "%s;",$i}printf "%s\n",$NF}')
    a=("${a[@]}" "$newLine") # add to the end
    [ "${#a[@]}" -gt $winsize ] && {
      a=(${a[@]:1}) # pop from the front
      seconds=$((seconds+1))
    }
    tc=0
    for i in ${a[@]}; do
      echo "$((seconds+tc)) $(echo $i|awk -F\; '{for(i=1;i<NF;++i){printf "%s ",$i}printf "%s\n",$NF}')"
      tc=$((tc+1))
    done
    echo e # gnuplot's end of dataset marker
  }
done

