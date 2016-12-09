#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#░█▀▀░█░█░█▀▀░█░░░█░░░░░█▀▀░█░█░█▀█░█▀▀░▀█▀░▀█▀░█▀█░█▀█░█▀▀
#░▀▀█░█▀█░█▀▀░█░░░█░░░░░█▀▀░█░█░█░█░█░░░░█░░░█░░█░█░█░█░▀▀█
#░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀▀▀░░░▀░░░▀▀▀░▀░▀░▀▀▀░░▀░░▀▀▀░▀▀▀░▀░▀░▀▀▀
#┃           Maintained at https://is.gd/jfAQYX            ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛


# use grc if it's installed or execute the command direct
grc() {
  if [[ -n "$(which grc)" ]]; then
    #grc --colour=auto
    $(which grc) --colour=on "$@"
  else
    "$@"
  fi
}

# adds files permissons in binary form to the ls command output
lso()
{
  if [ -t 0 ];then ls -alG "$@";else cat -;fi |
    awk '{t=$0;gsub(/\x1B\[[0-9;]*[mK]/,"");k=0;for(i=0;i<=8;i++)k+=((substr($1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(" %0o ",k);print t}'
}

# watches input command output through a banner
# Usage: showbanner "date +%T"
showbanner()
{
  local opt; local t=1; local cmd

  OPTIND=1 #reset index
  while getopts "t:" opt; do
    case $opt in
      t)  t=$OPTARG ;;
      \?) return 1 ;;
      :)  echo "Option -$OPTARG requires number of sec as an argument" >&2;return 1 ;;
    esac
  done
  shift $((OPTIND-1));
  cmd=echo
  [ -n "$BANNER" ] && cmd="$BANNER"
  watch --color -tn${t} "$@|xargs $cmd"
}

# cli calculator. Usage: ? "sqrt(3)/2 + 4"
function ? {
  awk "BEGIN{ pi = 4.0*atan2(1.0,1.0); deg = pi/180.0; print $@ }"
}

# crypting functions
encrypt() {
  if [ -t 0 ]; then
    # interactive
    local fname="$1"
    shift
    openssl aes-256-cbc -salt -in "$fname" -out "${fname}.enc" $@
  else
    # piped
    perl -e 'use IO::Select; $ready=IO::Select->new(STDIN)->can_read();'
    openssl aes-256-cbc -salt $@
  fi
}
decrypt() {
  if [ -t 0 ]; then
    # interactive
    local fname="$1"
    shift
    openssl aes-256-cbc -d -in "$fname" -out "${fname%\.*}" $@
  else
    perl -e 'use IO::Select; $ready=IO::Select->new(STDIN)->can_read();'
    openssl aes-256-cbc -d $@
  fi
}

# shows weather in a city
wttr() {
  wttrfull $@ | head -n 7
}
wttrfull() {
  wget -q -O - http://wttr.in/$1
}

# transfer a file or pipe to the server
# 10G maximum for 14 days
transfer() {
  local basefile;local tmpfile
  if [ $# -eq 0 ]; then
    echo "No arguments specified. Usage:"
    echo "  transfer /tmp/test.md"
    echo "  cat /tmp/test.md | transfer test.md";
    return 1;
  fi
  tmpfile=$(mktemp -t transferXXX);
  if tty -s; then
    basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g');
    curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile;
  else
    curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile;
  fi;
  cat $tmpfile|tee >(xclip -i -sel c)
  rm -f $tmpfile;
} 

# sets random wallpaper image
randomwallpaper() {
  local wpath=${1:-~/wallpapers}
  [[ -d "$wpath" ]] || wpath=/usr/share/xfce4/backdrops/
  \feh --bg-scale "$(find "${wpath}" -iname '*'|shuf|head -n1)"
}

# select a wallpaper interactively and set it
wallpaper() {
  local wname;local warr
  local wdir=${1:-~/wallpapers}
  [[ -d "$wdir" ]] || wdir=/usr/share/xfce4/backdrops/
  local TIFS=$IFS;IFS=$'\n';warr=( $(\ls "$wdir") );IFS=$TIFS
  wname=$(/usr/bin/yad --entry --title "Available wallpapers" --text "Choose wallpaper image" --entry-text "${warr[@]}" 2>/dev/null)
  [[ -n "$wname" ]] && feh --bg-scale "$(find "${wdir}" -iname "$wname"|shuf|head -n1)"
}

# copies a file and shows progress
copy() {
  local size=$(stat -c%s $1)
  [[ -z "$1" || -z "$2" ]] && {
    echo "Usage: copy /source/file /destination/file"
    return 1
  }
  local dest=$2
  [[ -d "$dest" ]] && dest="$2/$(basename $1)"
  dd if=$1 2> /dev/null | pv -petrb -s $size | dd of=$dest
}

#pb pastebin || Usage: 'command | pb or  pb filename'
pb() {
  curl -F "c=@${1:--}" https://ptpb.pw/
}
pbs() {
  local sname=$(scrot "$1" '/tmp/screenshot_$w_$h_%F_%H-%M-%S.png' -e 'echo $f')
  [[ -s "$sname" ]] && pbx $sname
}
pbsw() {
  echo "Select window to upload"
  pbs -s
}
pbx() {
  read -p "Upload screenshot $1? [yN]:"
  [[ "y" = "$REPLY" ]] && {
    curl -sF "c=@${1:--}" -w "%{redirect_url}" 'https://ptpb.pw/?r=1' -o /dev/stderr | xclip -i -sel c
  }
}

# search command usage examples on commandlinefu.com
cmdfu() {
  curl "http://www.commandlinefu.com/commands/matching/$(echo "$@" \
        | sed 's/ /-/g')/$(echo -n $@ | base64)/plaintext" ;
}

# url escape / unescape
urlencode() {
  local i c url
  url="$1"
  [[ -z "$url" ]] && url=$(cat -)
  for (( i=0 ; i<${#url} ; i++ )); do
    c=${url:$i:1}
    case "$c" in
      [-_.~a-zA-Z0-9] ) printf "$c" ;;
      * )               printf '%%%02x' "'$c" ;;
    esac
  done
}

urldecode() {
  local url
  url="$1"
  [[ -z "$url" ]] && url=$(cat -)
  printf '%b' "${url//%/\\x}"
}

# shorten / expand a URL
shortenurl() {
#    curl -F"shorten=$*" https://0x0.st
#  wget -q -O - --post-data="shorten=$1" https://0x0.st
  local url=$1
  [[ -z "$url" ]] && url=$(xclip -o -sel c 2>/dev/null)
  [[ -z "$url" ]] && echo "Nothing to shorten" && return 1
  wget -q -O - 'http://is.gd/create.php?format=simple&url='"$(urlencode "$url")"|tee >(xclip -i -sel c);echo
}
expandurl() {
  local url=$1
  [[ -z "$url" ]] && url=$(xclip -o -sel c 2>/dev/null)
  [[ -z "$url" ]] && echo "Nothing to expand" && return 1
  wget -S "$url" 2>&1 | grep ^Location | awk '{print $2}'|tee >(xclip -i -sel c)
}

# kernel graph
kernelgraph() {
  lsmod | perl -e 'print "digraph \"lsmod\" {";
                   <>;
                   while(<>){
                     @_=split/\s+/;
                     print "\"$_[0]\" -> \"$_\"\n" for split/,/,$_[3]
                   }
                   print "}"' | dot -Tsvg | rsvg-view-3 /dev/stdin
}

# system info
sinfo () {
  echo -ne "${LIGHTRED}CPU:$NC";sed -nr  's/model name[^:*]: (.*)/\t\1/p' /proc/cpuinfo
  echo -ne "${LIGHTRED}MEMORY:$NC\t";cat /proc/meminfo | awk '/MemTotal/{mt=$2};/MemFree/{mf=$2};/MemAvail/{ma=$2}END{print "Total: "mt" | Free: "mf" | Available: "ma" (kB)"}'
  echo -ne "${LIGHTRED}OS:$NC\t";cat /etc/issue | awk '{ if (NF>=2){$NF="";$(NF-1)="";print $0;} }'
  echo -ne "${LIGHTRED}KERNEL:$NC\t";uname -a | awk '{ print $3 }'
  echo -ne "${LIGHTRED}ARCH:$NC\t";uname -m
  echo -ne "${LIGHTRED}UPTIME:$NC\t";uptime -p
  echo -ne "${LIGHTRED}USERS:$NC\t";w -h | awk '{print $1}'|uniq|awk '{users=users$1" "}END{print users}'
  echo -ne "${LIGHTRED}TEMPER:$NC\t";awk -v t="$(cat /sys/class/thermal/thermal_zone0/temp)" 'BEGIN{print t/1000}'
  echo -ne "${LIGHTRED}DISK:$NC";df -h | grep -e"/dev/sd" -e"/mnt/" | awk '{print "\t"$0}'

}

# remove last n records from history
delhistory() {
  local n=1
  while getopts "n:" opt; do
    case $opt in
      n)  n=$OPTARG ;;
      \?) return 1 ;;
      :)  echo "Option -$OPTARG requires number of history last entries to remove as an argument" >&2;return 1 ;;
    esac
  done
  history | tail -n $n | tac  
}
