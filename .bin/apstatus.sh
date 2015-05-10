#!/bin/bash

set -o pipefail
iface=${1:-wlan0}
r=$(iwconfig $iface|awk '/ESSID:/{split($0,a,/\"/);print a[2]};\
                        /Frequency:/{split($0,a,/Frequency:/);split(a[2],a,/\ /);print a[1]};\
                        /Link\ Quality/ {split($2,a,/=/);print a[2]}')
[[ $? -ne 0 ]] && exit 1

IFS=$'\n'
res=($r)

# to avoid status line jumping quality is multiplied with 99 below

if [[ "$1" == "-n" ]]; then
{
  printf "${res[0]}\n"
  exit 0
}
elif [[ "$1" == "-f" ]]; then
{
  echo "${res[1]} GHz"
  exit 0
}
elif [[ "$1" == "-s" ]]; then
{
  echo "$((99*${res[2]}))"
  exit 0
}
fi

printf "${res[0]} [$((99*${res[2]}))] ${res[1]} GHz\n"


