#!/bin/bash

cat - | gnuplot -e "set yrange [0:$1]; \
                    set term wxt noraise; \
                    set style fill transparent solid 0.5; \
                    plot '-' u 1:2 t 'Current' w filledcurves x1, '' u 1:3 t 'Average' w filledcurves x1 fc rgb 'blue'; \
                    do for [i=0:100000000]{replot}"
