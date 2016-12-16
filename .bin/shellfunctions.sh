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
# perl oneliner is to enable encrypt|decrypt combos
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
  local basefile tmpfile
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

# copies a file and shows progress
copy() {
  [[ -z "$1" || -z "$2" ]] && {
    echo "Usage: copy /source/file /destination/file"
    return 1
  }
  local dest=$2
  local size=$(stat -c%s $1)
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
  wget -qO - "http://www.commandlinefu.com/commands/matching/$(echo "$@" \
        | sed 's/ /-/g')/$(echo -n $@ | base64)/sort-by-votes/plaintext" ;
}

# url escape / unescape
urlencode() {
  local url="$1"
  [[ -z "$url" ]] && url=$(cat -)
  perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$url"
}
urldecode() {
  local url="$1"
  [[ -z "$url" ]] && url=$(cat -)
  perl -MURI::Escape -e 'print uri_unescape($ARGV[0]);' "$url"
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

# shows battery status
showbatt() {
  local dir=/sys/class/power_supply/BAT0/
  echo "$(<"$dir"/status) $(( $(<"$dir"/charge_now) * 100 / $(<"$dir"/charge_full) ))%"
}

# system info
sinfo () {
  echo -ne "${LIGHTRED}CPU:$NC";sed -nr  's/model name[^:*]: (.*)/\t\1/p' /proc/cpuinfo
  echo -ne "${LIGHTRED}MEMORY:$NC\t";awk '/MemTotal/{mt=$2};/MemFree/{mf=$2};/MemAvail/{ma=$2}END{print "Total: "mt" | Free: "mf" | Available: "ma" (kB)"}' /proc/meminfo
  echo -ne "${LIGHTRED}OS:$NC\t";awk '{ if (NF>=2){$NF="";$(NF-1)="";print $0;} }' /etc/issue
  echo -ne "${LIGHTRED}KERNEL:$NC\t";uname -a | awk '{ print $3 }'
  echo -ne "${LIGHTRED}ARCH:$NC\t";uname -m
  echo -ne "${LIGHTRED}UPTIME:$NC\t";uptime -p
  echo -ne "${LIGHTRED}USERS:$NC\t";w -h | awk '{print $1}'|uniq|awk '{users=users$1" "}END{print users}'
  echo -ne "${LIGHTRED}TEMPER:$NC\t";awk -v t="$(cat /sys/class/thermal/thermal_zone0/temp)" 'BEGIN{print t/1000}'
  echo -ne "${LIGHTRED}BATTRY:$NC";echo " $(showbatt)"
  echo -ne "${LIGHTRED}DISK:$NC";df -h | grep -e"/dev/sd" -e"/mnt/" | awk '{print "\t"$0}'
}

# remove last n records from history
delhistory() {
  local opt id n=1
  OPTIND=1 #reset index
  while getopts "n:" opt; do
    case $opt in
      n)  n=$OPTARG ;;
      \?) return 1 ;;
      :)  echo "Option -$OPTARG requires number of history last entries to remove as an argument" >&2;return 1 ;;
    esac
  done

  ((++n));id=$(history | tail -n $n | head -n1 | awk '{print $1}')
  while ((n-- > 0)); do history -d $id; done
}

# poor man's mpd client
mpc() {
  echo "$@" | nc $MPDSERVER 6600
}

# mpd status display in the upper right terminal corner
mpdd() {
  local _r _l _p
  while sleep 1; do
    _r=$(awk 'BEGIN{FS=": "}
                /^Artist:/{r=r""$2};
                /^Title:/{r=r" - "$2};
                /^time:/{r=$2" "r};
                /^state: play/{f=1}
              END{if(f==1){print r}}' <(mpc status;mpc currentsong));

    _l=${#_r};
    [[ $_l -eq 0 ]] && continue;
    [[ -z "$_p" ]] && _p=$_l;
    echo -ne "\e[s\e[0;${_p}H\e[K\e[u";
    _p=$((COLUMNS - _l));
    echo -ne "\e[s\e[0;${_p}H\e[K\e[0;44m\e[1;33m${_r}\e[0m\e[u";
  done
}

# returns album art for the "artist - album" input string
# todo: do we need only [,] to be removed or some other chars too? 
getart() {
  [[ -z "$ARTDIR" ]] && local ARTDIR="$HOME/.cache/albumart"
  [[ -d "$ARTDIR" ]] || mkdir -p "$ARTDIR"

  local mpccurrent="$(echo "$@"|sed -r 's/(\[|\]|\,)//g')"
  local artfile=$(find $ARTDIR -iname "${mpccurrent}*")
  [[ -z "$artfile" ]] && {
    # customize useragent at http://whatsmyuseragent.com/
    local useragent='Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:31.0) Gecko/20100101 Firefox/31.0' local link="www.google.com/search?q=$(urlencode "$mpccurrent")\&tbm=isch"
    local imagelink ext imagepath
    local imagelinks=$(wget -e robots=off --user-agent "$useragent" -qO - "$link" | sed 's/</\n</g' | grep '<a href.*\(png\|jpg\|jpeg\)' | sed 's/.*imgurl=\([^&]*\)\&.*/\1/')
    for imagelink in $imagelinks; do
      imagelink=$(echo $imagelink | sed -nr 's/(.*\.(jpg|jpeg|png)).*/\1/p')
      ext=$(echo $imagelink | sed -nr 's/.*(\.(jpg|jpeg|png)).*/\1/p')
      imagepath="${ARTDIR}/${mpccurrent}${ext}"
      wget --max-redirect 0 -qO "$imagepath" "${imagelink}"
      [[ -s "$imagepath" ]] && break
      rm "$imagepath" # remove zero length file
    done
    artfile=$(find $ARTDIR -iname "${mpccurrent}*")
  }
  echo "$artfile"
}

# sends notifications for the new title
notifyart() {
  local artist album title oldartist oldtitle
  while true; do
    artist=$(mpc currentsong | awk -F": " '/^Artist:/{print $2}')
    title=$(mpc currentsong | awk -F": " '/^Title:/{print $2}')
    album=$(mpc currentsong | awk -F": " '/^Album:/{print $2}')
    [[ -z "$album" ]] && album="$title"
    [[ "$artist" != "$oldartist" ]] || [[ "$title" != "$oldtitle" ]] && {
      notify-send "$title" "$artist" -i "$(getart "$artist - $album")" -t 5000
      oldartist="$artist"
      oldtitle="$title"
    } 
    sleep 2
  done 
}

# purge all packages marked as rc with the dpkg
purgerc() {
  dpkg -l |grep "^rc" | cut -d " " -f 3 | xargs sudo dpkg --purge
}
