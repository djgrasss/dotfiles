#!/bin/bash

# Usage example: 
# ((cpustat.sh 0 | (while read line; do echo "0:$line";done)) & \
#  (cpustat.sh 1 | (while read line; do echo "1:$line";done)) & \
#  (cpustat.sh 2 | (while read line; do echo "2:$line";done)) & \
#  (cpustat.sh 3 | (while read line; do echo "3:$line";done))) | \
#  bin/combinepipes.sh 4
# by default 2 pipes are combined
pipes=${1:-2}

awk -F: -v pipes=$pipes 'BEGIN {cnt=0}
                         {
                           a[$1]=$2; cnt++;
                           if(cnt>pipes-1) {
                             i=0;
                             while(i<cnt) {
                               printf("%s ", a[i++])
                             }
                             printf("\n")
                             fflush()
                             cnt=0;
                           }
                         }' -

