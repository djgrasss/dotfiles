#!/bin/bash

terminal="qt"     # terminal type (x11,wxt,qt)
range=${1:-0:100} # min:max values of displayed y range.
                   # ":" for +/- infinity. Default "0:100"
shift              # the rest are the titles

declare -A styles_def
styles_def=( [0]="filledcurves x1" [1]="boxes" [2]="lines" [3]="points" )
# remove the color adjustment line below to get
# default gnuplot colors for the first six plots
colors_def=("red" "blue" "green" "yellow" "cyan" "magenta")
colors=( "${colors_def[@]}" )

# parsing input plots descriptions
i=0
IFS=$';'
while [ -n "$1" ]; do
  tmparr=( $1 )
  titles[$i]=${tmparr[0]}
  styles[$i]=${styles_def[${tmparr[1]}]-${tmparr[1]}}
  [ -n "${styles[$i]}" ] || {styles=${styles_def[0]}}
  colors[$i]=${tmparr[2]-${colors_def[$i]}}
  xy[$i]=${tmparr[3]}
  i=$((i+1))
  shift
done

tmparr=( $range )
yrange=${tmparr[0]}
xrange=${tmparr[1]}
IFS=$'\n'

samples=0          # samples counter
(while read newLine; do
  if [ -n "$newLine" ]; then
    a=("${a[@]}" "$newLine") # add to the end
  else
    #nf=$(echo "$newLine"|awk '{print NF}')
    nf=0;TMPIFS=$IFS;IFS=$' 	\n'
      for j in ${a[0]};do nf=$((nf+1));done
    IFS=$TMPIFS
    echo "set term $(echo $terminal) noraise"
    echo "set yrange [$yrange]"
    if [ -n "$xrange" ]; then
      echo "set xrange [$xrange]"
    else
      echo "set xrange [-0.5:$((${#a[@]}-1)).5]"
    fi
    echo "set style fill transparent solid 0.5"
    echo -n "plot "
    for ((j=0;j<$nf;++j)); do
      c1=1;
      c2=$((j+2));
      [ -n "${xy[j]}" ] && {
        c1=$((j+2));
        c2=$((j+3));
      }
      echo -n " '-' u $c1:$c2 t '${titles[$j]}' "
      echo -n "w ${styles[$j]-${styles_def[0]}} "
      [ -n "${colors[$j]}" ] && echo -n "fc rgb '${colors[$j]}'"
      echo -n ","
      [ $c1 = 1 ] || j=$((j+1))
    done
    echo
    for ((j=0;j<$nf;++j)); do
      tc=0 # temp counter
      for i in ${a[@]}; do
        echo "$tc $i"
        tc=$((tc+1))
      done
      echo e # gnuplot's end of dataset marker
    done
    unset a
  fi 
done) | gnuplot 2>/dev/null

