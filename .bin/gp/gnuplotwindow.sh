#!/bin/bash

winsize=${1:-60}   # number of samples to show
yrange=${2:-0:100} # min:max values of displayed y range.
                   # ":" for +/- infinity. Default "0:100"
shift;shift        # the rest are the titles

terminal="wxt"     # terminal type (x11,wxt,qt)
style="w filledcurves x1"
#style="w boxes"
#style="w lines"

samples=0          # samples counter
IFS='\n'
titles=( "$@" )
colors=( "red" "blue" "green" "yellow" "cyan" "magenta")
while read newLine; do
  [ -n "$newLine" ] && {
    nf=$(echo "$newLine"|awk '{print NF}')
    a=("${a[@]}" "$newLine") # add to the end
    [ "${#a[@]}" -gt $winsize ] && {
      a=("${a[@]:1}") # pop from the front
      samples=$((samples + 1))
    }
    echo "set term $(echo $terminal) noraise"
    echo "set yrange [$yrange]"
    echo "set xrange [${samples}:$((samples+${#a[@]}-1))]"
    echo "set style fill transparent solid 0.5"
    echo -n "plot "
    for ((j=0;j<$nf;++j)); do
      echo -n " '-' u 1:$((j+2)) t '${titles[$j]}' "
      echo -n "$style "
      [ -n "${colors[$j]}" ] && echo -n "fc rgb '${colors[$j]}'"
      echo -n ","
    done
    echo
    for ((j=0;j<$nf;++j)); do
      tc=0 # temp counter
      for i in ${a[@]}; do
        echo "$((samples+tc)) $i"
        tc=$((tc+1))
      done
      echo e # gnuplot's end of dataset marker
    done
  }
done | gnuplot 2>/dev/null

