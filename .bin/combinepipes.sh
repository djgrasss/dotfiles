#!/bin/bash

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

