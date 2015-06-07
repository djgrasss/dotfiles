#!/bin/bash

winsize=${1:-60} # number of samples to store
maxval=${2:-100} # maximum value of displayed range
legend1=${3:-Current} #
legend2=${4:-Avarage} #

samples=0        # samples counter
IFS='\n'
while read newLine; do
  [ -n "$newLine" ] && {
    a=("${a[@]}" "$newLine") # add to the end
    [ "${#a[@]}" -gt $winsize ] && {
      a=("${a[@]:1}") # pop from the front
      samples=$((samples + 1))
    }
    tc=0 # temp counter
    for i in ${a[@]}; do
      echo "$((samples+tc)) $i"
      tc=$((tc+1))
    done
    echo e # gnuplot's end of dataset marker
  }
done | gnuplot -e "set yrange [0:$maxval]; \
                   set term wxt noraise; \
                   set style fill transparent solid 0.5; \
                   plot '-' u 1:2 t '$legend1' w filledcurves x1, '' u 1:3 t '$legend2' w filledcurves x1 fc rgb 'blue'; \
                   do for [i=0:100000000]{replot}" 2>/dev/null

