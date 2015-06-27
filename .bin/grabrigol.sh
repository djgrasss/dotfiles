#/bin/bash

print_usage_exit()
{
  echo "Usage: $0 riogl_scope_ip_address [output_file_name_without_extension]"
  echo "Example: $0 192.168.1.123 \"\$(date +"rigol.screenshot.%Y.%m.%d.%H.%M.%S")\""
  exit 1
}

outfmt=png
outfile="$2"
[ -z "$1" ] && print_usage_exit
[ -z "$outfile" ] && outfile="/proc/self/fd/1"
[ -z "$(which convert)" ] && outfmt=bmp

#echo "*idn?" | nc "$1" 5555
echo "display:data?" | nc "$1" 5555 | dd bs=1 skip=11 2>/dev/null | \
  if [ "bmp" = "$outfmt" ]; then cat >"${outfile}.bmp";else convert bmp:- "${outfile}.png";fi 

