#!/bin/bash

function zpk3D
{
  local m=$1
  local ban=$2
  local xsign=$3
  local ysign=$4
  local zsign=$5

  case "$ban" in
   1)
    [ $m -gt 2 ] && zpk3D $((m/2))  6  $((xsign*-1))  $((ysign*-1))  $zsign;
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Z=$((Z+zsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 3  $xsign  $ysign  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    X=$((X+xsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 3  $xsign  $ysign  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Z=$((Z-zsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 5  $((xsign*-1))  $ysign  $((zsign*-1))
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Y=$((Y+ysign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 5  $((xsign*-1))  $ysign  $((zsign*-1))
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Z=$((Z+zsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 3  $((xsign*-1))  $((ysign*-1))  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    X=$((X-xsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 3  $((xsign*-1))  $((ysign*-1))  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Z=$((Z-zsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 6  $((xsign*-1))  $ysign  $((zsign*-1))
    [ $m -gt 2 ] || awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    ;;
   2)
    [ $m -gt 2 ] && zpk3D $((m/2)) 5  $xsign  $ysign  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Y=$((Y+ysign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 4  $((xsign*-1))  $((ysign*-1))  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    X=$((X+xsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 4  $((xsign*-1))  $((ysign*-1))  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Y=$((Y-ysign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 6  $xsign  $ysign  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Z=$((Z+zsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 6  $xsign  $ysign  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Y=$((Y+ysign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 4  $xsign  $((ysign*-1))  $((zsign*-1))
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    X=$((X-xsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 4  $xsign  $((ysign*-1))  $((zsign*-1))
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Y=$((Y-ysign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 5  $xsign  $((ysign*-1))  $((zsign*-1))
    [ $m -gt 2 ] || awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    ;;
   3)
    [ $m -gt 2 ] && zpk3D $((m/2)) 1  $xsign  $ysign  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Y=$((Y+ysign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 6  $((xsign*-1))  $((ysign*-1))  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Z=$((Z+zsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 6  $((xsign*-1))  $((ysign*-1))  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Y=$((Y-ysign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 4  $((xsign*-1))  $ysign  $((zsign*-1))
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    X=$((X+xsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 4  $((xsign*-1))  $ysign  $((zsign*-1))
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Y=$((Y+ysign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 6  $xsign  $((ysign*-1))  $((zsign*-1))
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Z=$((Z-zsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 6  $xsign  $((ysign*-1))  $((zsign*-1))
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Y=$((Y-ysign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 1  $((xsign*-1))  $((ysign*-1))  $zsign
    [ $m -gt 2 ] || awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    ;;
   4)
    [ $m -gt 2 ] && zpk3D $((m/2)) 2  $((xsign*-1))  $((ysign*-1))  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Z=$((Z+zsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 5  $((xsign*-1))  $((ysign*-1))  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Y=$((Y-ysign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 5  $((xsign*-1))  $((ysign*-1))  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Z=$((Z-zsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 3  $((xsign*-1))  $ysign  $((zsign*-1))
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    X=$((X-xsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 3  $((xsign*-1))  $ysign  $((zsign*-1))
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Z=$((Z+zsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 5  $xsign  $ysign  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Y=$((Y+ysign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 5  $xsign  $ysign  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Z=$((Z-zsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 2  $xsign  $((ysign*-1))  $((zsign*-1))
    [ $m -gt 2 ] || awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    ;;
   5)
    [ $m -gt 2 ] && zpk3D $((m/2)) 4  $((xsign*-1))  $((ysign*-1))  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    X=$((X+xsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 2  $xsign  $ysign  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Z=$((Z+zsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 2  $xsign  $ysign  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    X=$((X-xsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 1  $((xsign*-1))  $ysign  $((zsign*-1))
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Y=$((Y+ysign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 1  $((xsign*-1))  $ysign  $((zsign*-1))
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    X=$((X+xsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 2  $xsign  $((ysign*-1))  $((zsign*-1))
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Z=$((Z-zsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 2  $xsign  $((ysign*-1))  $((zsign*-1))
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    X=$((X-xsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 4  $xsign  $ysign  $zsign
    [ $m -gt 2 ] || awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    ;;
   6)
    [ $m -gt 2 ] && zpk3D $((m/2)) 3  $((xsign*-1))  $((ysign*-1))  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    X=$((X-xsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 1  $((xsign*-1))  $((ysign*-1))  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Y=$((Y-ysign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 1  $((xsign*-1))  $((ysign*-1))  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    X=$((X+xsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 2  $xsign  $ysign  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Z=$((Z+zsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 2  $xsign  $ysign  $zsign
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    X=$((X-xsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 1  $((xsign*-1))  $ysign  $((zsign*-1))
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    Y=$((Y+ysign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 1  $((xsign*-1))  $ysign  $((zsign*-1))
    awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    X=$((X+xsign));
    [ $m -gt 2 ] && zpk3D $((m/2)) 3  $xsign  $((ysign*-1))  $((zsign*-1))
    [ $m -gt 2 ] || awk -v x=$X -v y=$Y -v z=$Z -v n=$((N-1)) 'BEGIN{print x/n" "y/n" "z/n}'
    ;;
   *) echo "Error: zpk rotation index is wrong: $m" >&2;;
  esac 
}

iteration=${1:-1}

while true; do
  N=$((1<<iteration))
  X=0; Y=0; Z=0;
  zpk3D $N 1  1 1 1
  echo

  while true; do
    read -s -n1 c
    case $c in
      s) [ $iteration -gt 1 ] && iteration=$((iteration-1));break ;;
      w) [ $iteration -lt 8 ] && iteration=$((iteration+1));break ;;
      *) echo >&2
    esac
  done
done

