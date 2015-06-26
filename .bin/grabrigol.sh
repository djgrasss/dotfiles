#/bin/bash

print_usage_exit()
{
  echo "Usage: $0 riogl_scope_ip_address [output_file_name.bmp]"
  echo "Example: $0 192.168.1.123 \"\$(date +"rigol.screenshot.%Y.%m.%d.%H.%M.%S.bmp")\""
  exit 1
}

bmpfile="$2"
[ -z "$1" ] && print_usage_exit
[ -z "$outfile" ] && bmpfile="/proc/self/fd/1"

#echo "*idn?" | nc "$1" 5555 #> /tmp/image.png
echo "display:data?" | nc "$1" 5555 | dd bs=1 skip=11 of="$bmpfile" 2>/dev/null

