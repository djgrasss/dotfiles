#!/bin/bash

print_usage_exit()
{
  {
  [ -n "$1" ] && echo -e "ERROR: $1\n"
  echo "Usage: $0 [-dN] [-pN] directory_path"
  echo "       -d N sets slideshow delay in seconds; default is 3"
  echo "       -p N port to bind; default 12345"
  } >&2
  exit 1
}

DELAY=3
PORT=12345

while getopts ":p:d:" opt; do
  case $opt in
      d) DELAY=$OPTARG ;;
      p) PORT=$OPTARG ;;
     \?) print_usage_exit "Invalid option: $OPTARG" ;;
      :) print_usage_exit "Option $OPTARG requires an argument" ;;
  esac
done
shift $((OPTIND-1))

[ $DELAY -eq $DELAY ] 2>/dev/null || print_usage_exit "Delay argument is $DELAY but it should be an integer"
[ $PORT -eq $PORT ] 2>/dev/null || print_usage_exit "Port argument is $PORT but it should be an integer"
[ -d "$1" ] || print_usage_exit "Directory $1 does not exist"

(while :; do for i in $1/*;do echo "$i"; sleep $DELAY;done;done) | \
  (echo -ne "HTTP/1.1 200 OK\r\nContent-Type: multipart/x-mixed-replace;";\
   echo -ne "boundary=myboundary\r\n\r\n--myboundary\r\n";\
   while read pic; do \
     echo -ne "Content-Type: image/jpeg\r\n\r\n";\
     cat "$pic";\
     echo -ne "\r\n--myboundary\r\n";\
   done \
  ) | nc -l $PORT

