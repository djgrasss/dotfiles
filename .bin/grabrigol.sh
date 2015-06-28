#/bin/bash

print_usage_examples()
{
  echo "Examples:"
  echo 
  echo "Save screenshot as a png:" 
  echo "  $0 -c 192.168.1.123 \"\$(date +"rigol.screenshot.%Y.%m.%d.%H.%M.%S.png")\""
  echo 
  echo "Create an HTTP server on port 12345 serving scope's screenshots:" 
  echo "while :;do \\"
  echo "  (echo -ne \"HTTP/1.1 200 OK\\r\\n\";\\"
  echo "   echo -ne \"\$(date +'Date: %c')\\r\\n\";\\"
  echo "   echo -ne \"Content-Type: image/bmp\\r\\n\\r\\n\";\\"
  echo "   $0 192.168.1.123)|nc -l 12345; done"
  echo 
  echo "Create an HTTP server on port 12345 serving scope's screenshots as"
  echo "a  MJPG stream with 1 screenshot in 5 seconds:" 
  echo "(while :;do echo;sleep 5;done) | \\"
  echo "  (echo -ne \"HTTP/1.1 200 OK\\r\\nContent-Type: multipart/x-mixed-replace;\";\\"
  echo "   echo -ne \"boundary=myboundary\\r\\n\\r\\n--myboundary\\r\\n\";\\"
  echo "   while read; do\\"
  echo "     echo -ne \"Content-Type: image/jpeg\\r\\n\\r\\n\";\\"
  echo "     $0 192.168.1.123 | convert bmp:- jpeg:-;\\"
  echo "     echo -ne \"\\r\\n--myboundary\\r\\n\";\\"
  echo "   done) | nc -l 12345"

  exit 0
} 

print_usage_exit()
{
  echo "Usage: $0 [-ec] riogl_scope_ip_address [output_file_name]"
  echo "       -e shows usage examples"
  echo "       -c will try to convert a bmp stream into a png"
  echo "          If ImageMagic is missing the bmp stream is output and a warning"
  echo "       If output file name is missing the stdout will be used"
  exit 1
}

while getopts ":c:e" opt; do
  case $opt in
      e) print_usage_examples;;
      c) doPng=1;shift $((OPTIND-1));;
     \?) print_usage_exit;;
  esac
done

[ -z "$1" ] && print_usage_exit
outfile="$2"

[ -z "$outfile" ] && outfile="/proc/self/fd/1"
[ -n "$doPng" -a -z "$(which convert)" ] && { 
  unset doPng
  echo "WARNING: convert utility is not found, BMP is streamed" >&2
}

#echo "*idn?" | nc "$1" 5555
echo "display:data?" | nc "$1" 5555 | dd bs=1 skip=11 2>/dev/null | \
  if [ -z "$doPng" ]; then cat >"$outfile";else convert bmp:- "${outfile}";fi 

