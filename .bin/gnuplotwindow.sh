#!/bin/bash

winsize=${1:-60} # number of samples to store
maxval=${2:-100} # maximum value of displayed range
legend1=${3:-Current} #

samples=0        # samples counter
IFS='\n'
while read newLine; do
  [ -n "$newLine" ] && {
    nf=$(echo "$newLine"|awk '{print NF}')
    a=("${a[@]}" "$newLine") # add to the end
    [ "${#a[@]}" -gt $winsize ] && {
      a=("${a[@]:1}") # pop from the front
      samples=$((samples + 1))
    }
    for ((j=0;j<$nf;++j)); do
      tc=0 # temp counter
      for i in ${a[@]}; do
        echo "$((samples+tc)) $i"
        tc=$((tc+1))
      done
      echo e # gnuplot's end of dataset marker
    done
  }
done | gnuplot -e "set yrange [0:$maxval]; \
                   set term wxt noraise; \
                   set xtics 0,1 rotate nomirror scale 0.0 font 'default,6'; \
                   set style fill transparent solid 0.5; \
                   plot '-' u 1:2 t '$legend1' w filledcurves x1 fc rgb 'red'\
$([ -n "$4" ] && echo  ','\''-'\'' u 1:3 t '\'$4\'' w filledcurves x1 fc rgb '\''blue'\')\
$([ -n "$5" ] && echo  ','\''-'\'' u 1:4 t '\'$5\'' w filledcurves x1 fc rgb '\''green'\')\
$([ -n "$6" ] && echo  ','\''-'\'' u 1:5 t '\'$6\'' w filledcurves x1 fc rgb '\''yellow'\')\
                   ;
                   do for [i=0:100000000]{replot}" 2>/dev/null

