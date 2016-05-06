#!/bin/bash

indir=/tmp/lib1/russian
outdir=/tmp/conv2
rarout=/tmp/arc

[ ! -d "$outdir" ] && mkdir "$outdir"

for i in $indir/*
do
  [ -d "$i" ] && {
    outname="${outdir}/$(basename "$i")"
    [ ! -d "$outname"  ] && {
      mkdir "$outname" 
    } 

    for j in $i/*.rar
    do
      rarname="${rarout}/$(basename "$i")"
      [ ! -d "$rarname" ] && {
        mkdir "$rarname" 
      }
      rar x -y "$j" "$rarname"
    done
  }
done

