#!/bin/bash

N=${1:-50}      # number of columns
M=${2:-50}      # number of rows
fill=${3:-60}   # initial array fill factor in percent
iter=${4:-1e20} # default is endless. Use 'keyboard' to step with Enter

awk -v N=$N -v M=$M -v maxiter=$iter -v fill=$fill '
function init(a,N,M,probperc,     NM,i)
{
  NM=N*M;
  srand();
  for(i=0;i<NM;++i) {
    if(int(100*rand())>=probperc) {a[i]=1;}
    else {a[i]=0;}
  }
}

BEGIN {
  NM=N*M;
  NM_1=N*(M-1);
  iter=0;
  if (maxiter=="keyboard") {keyboard=1;maxiter=1e20;}
  else {maxiter+=0;} # to turn string into number
  init(a,N,M,fill);
  while (iter<maxiter) {
#for(j=0;j<NM;++j) {printf("%d",a[j]);if(0==((j+1)%N)){print "";}}
    for(row=0;row<M;++row) {
      trow=row*N;
      for(col=0;col<N;++col) {
        d=0;
        if (0==row) {crow=NM_1;} else{crow=trow-N;}
        d+=a[crow+((col+1+N)%N)] + a[crow+((col-1+N)%N)] + a[crow+((col+N)%N)];
        crow=trow;
        d+=a[crow+((col-1+N)%N)] + a[crow+((col+1+N)%N)];
        if ((M-1)==row) {crow=0;} else{crow=trow+N;}
        d+=a[crow+((col+1+N)%N)] + a[crow+((col-1+N)%N)] + a[crow+((col+N)%N)];
        idx=trow+col;
        if (d<2 || d>3) {b[idx] = 0;} # cell dies
        else if (3==d) {b[idx] = 1;}  # cell is born
        else {b[idx]=a[idx];}         # cell is preserved
      }
    }
    cellcount=0;
    for (i=0;i<NM;++i) {
      if (1==a[i]) {++cellcount;print i%N" "int(i/N);}
      a[i]=b[i];
    }
    print ""
    print iter" "cellcount > "/dev/stderr"
    ++iter;
#    if (0==cellcount) {iter=maxiter;}
    fflush();
    if (1==keyboard){getline line;}
  }
}'

