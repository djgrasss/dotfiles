#!/bin/bash

terminal="qt"      # terminal type (x11,wxt,qt)
range=${1:-0:100}  # min:max values of displayed y range.
                   # ":" for +/- infinity. Default "0:100"
shift              # the rest are the titles

# titles definitions examples:
# - "Spectrum;1;blue"
# - "Scatter plot;points pointtype 5 pointsize 10;red;xy"
# - "3D plot;2;#903489;3d;32;32"

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
  [ -n "${tmparr[1]}" ] || tmparr[1]=0
  styles[$i]=${styles_def[${tmparr[1]}]-${tmparr[1]}}
  [ -n "${styles[$i]}" ] || {styles=${styles_def[0]}}
  colors[$i]=${tmparr[2]-${colors_def[$i]}}
  dtype[$i]=${tmparr[3]}
  dtype_arg[$i]=${tmparr[4]}
  dtype_arg2[$i]=${tmparr[5]}
  [ "${dtype[$i]}" = "xy" ] && i=$((i+1))
  i=$((i+1))
  shift
done

tmparr=( $range )
xrange=${tmparr[0]}
yrange=${tmparr[1]}
zrange=${tmparr[2]}
IFS=$'\n'
blocks=0          # blocks counter
(
 echo "set term $(echo $terminal) noraise"
 echo "set style fill transparent solid 0.5"

 echo "set xrange [$xrange]"
 echo "set yrange [$yrange]"
 echo "set zrange [$zrange]"
 echo "set hidden3d"
 echo "set dgrid3d 32,32 gauss 0.25"

 while read newLine; do
  if [ -n "$newLine" ]; then
    a=("${a[@]}" "$newLine") # add to the end
  else
    blocks=$((blocks+1))
    #nf=$(echo "$newLine"|awk '{print NF}')
    nf=0;TMPIFS=$IFS;IFS=$' 	\n'
      for j in ${a[0]};do nf=$((nf+1));done
    IFS=$TMPIFS
    if [[ "${dtype[0]}" =~ ^3d.* ]]; then
      if [ "${dtype[0]}" = "3d" ] || [ $((blocks%dtype_arg2[0])) -eq 1 ]; then 
        echo -n "splot "
        echo -n "'-' u 1:2:3 t '${titles[0]}' "
        echo -n "w ${styles[0]-${styles_def[0]}} "
        [ -n "${colors[0]}" ] && echo -n "fc rgb '${colors[0]}'"
        echo -n ","
      fi
    else
      echo -n "plot "
      for ((j=0;j<$nf;++j)); do
        c1=1; c2=$((j+2));
        [ "${dtype[j]}" = "xy" ] && {
          c1=$((j+2)); c2=$((j+3));
        }
        echo -n " '-' u $c1:$c2 t '${titles[$j]}' "
        echo -n "w ${styles[$j]-${styles_def[0]}} "
        [ -n "${colors[$j]}" ] && echo -n "fc rgb '${colors[$j]}'"
        echo -n ","
        [ $c1 = 1 ] || j=$((j+1))
      done
    fi
    echo
    if [ "${dtype[0]}" = "3d" ]; then
      [ ${#a[@]} -gt $((dtype_arg[0]*dtype_arg2[0])) ] && {
        a=( "${a[@]:dtype_arg[0]}" )
      }
      for ((j=1;j<=dtype_arg2[0];++j)); do
        [ -n "${a[(dtype_arg2[0]-j)*${dtype_arg[0]}]}" ] || continue;
        for ((i=0;i<dtype_arg[0];++i)); do
          echo  "$i $j ${a[(dtype_arg2[0]-j)*${dtype_arg[0]}+i]}"
        done
      done
      echo e # gnuplot's end of dataset marker
    elif [ "${dtype[0]}" = "3db" ]; then
      for ((i=0;i<dtype_arg[0];++i)); do
        echo  "$i $((blocks%dtype_arg2[0])) ${a[i]}"
      done
      unset a
      [ $((blocks%dtype_arg2[0])) -eq 0 ] && {
        echo e # gnuplot's end of dataset marker
      }
    else
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
  fi 
done) | gnuplot 2>/dev/null

