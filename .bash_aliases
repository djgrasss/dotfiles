# Don't wait for job termination notification
set -o notify
shopt -s dotglob

# Ignore some controlling instructions
export HISTIGNORE="[   ]*:&:bg:fg:exit:ls:la:ll:l:ps:df:vim:vi:man*:info*:exit:dmesg:ifconfig:route:"
export HISTSIZE=-1     # unlimited
export HISTFILESIZE=-1 # unlimited
export HISTFILE=~/.bash_eternal_history
export HISTTIMEFORMAT='%F %T '
export EDITOR=vi

# grc as a function
function grc() {
  if [[ -n "$(which grc)" ]]; then
    #grc --colour=auto
    $(which grc) --colour=auto "$@"
  else
    "$@"
  fi
}

# aliases
alias less='less -r'                          # raw control characters
alias grep='grep --color'                     # show differences in colour

# Some shortcuts for different directory listings
alias dir='ls --color=auto --format=vertical'
alias vdir='ls --color=auto --format=long'
alias ll='ls -lA'                             # long list
alias la='ls -A'                              # all but . and ..
alias l='ls -CF'                              #
alias gr='grep -HEnri'                        #
alias rm='gvfs-trash'                         # safe rm

# my shortcuts
alias c='printf "\33[2J"'
alias ss='bc64=( {a..z} {A..Z} {0..9} + / = );c;while true; do echo -ne "\033[$((1+RANDOM%LINES));$((1+RANDOM%COLUMNS))H\033[$((RANDOM%2));3$((RANDOM%8))m${bc64[$((RANDOM%${#bc64[@]}))]}"; sleep 0.1 ; done'
alias p4='unset PWD; p4 '
alias ff='wget randomfunfacts.com -O - 2>/dev/null | grep \<strong\> | sed "s;^.*<i>\(.*\)</i>.*$;\1;"'
alias genpass='read -s tmppass; echo -n "$tmppass->"; echo $tmppass | md5sum | base64 | cut -c -16; unset tmppass'
alias 2edit='xsel -b;n=pipe$RANDOM;xdotool exec --terminator -- mousepad $n -- search --sync --onlyvisible --name $n key --window %1 ctrl+v'
alias 2win='xsel -b;n=pipe$RANDOM;xdotool exec --terminator -- subl $n -- search --sync --onlyvisible --name $n key --window %1 ctrl+v'
alias readpass='echo -n $(read -s passwd_;echo -n $passwd_)'
alias cdh='cd ~'
#alias timer='echo test;banr="banner";[ -z "which banner" ] && banr="cat";export banr;echo $banr;export ts=$(date +%s);p='\''$(date -u -d @"$(($(date +%s)-$ts))" +"%H.%M.%S")'\'';watch -n 1 -t $banr $p;eval "echo $p"'
alias timer='cmd=echo;[ -n "$(which banner)" ] && cmd=banner;export cmd;export ts=$(date +%s);p='\''$(date -u -d @"$(($(date +%s)-$ts))" +"%H.%M.%S")'\'';watch -n 1 -t $cmd $p;eval "echo $p"'
alias top10='ps aux --sort -rss | head'
alias traf='netstat -np | grep -v ^unix'
alias why='apt-cache rdepends --installed'
alias gc='git checkout'
alias gcb='git checkout -branch'
alias ga='git add'
alias gap='git add -p'
alias gs='git status'
alias gl='git log'
alias gb='git branch'
alias gd='git diff'

#coloring some programs using grc (check /usr/share/grc)
alias hexdump='grc hexdump'
alias ps='grc ps -A'
alias ping='grc ping'
alias ifconfig='grc ifconfig'
alias mount='grc mount'
alias df='grc df'
alias netstat='grc netstat'
alias gcc='grc gcc'
alias nmap='grc nmap'
alias cat='grc --colour=auto cat'
alias diff='grc --colour=auto diff'
alias ls='grc ls -X -hF --color=yes --group-directories-first'
alias tail='grc tail'

# setting the temp directory for vim
[ -z $TEMP ] && export TEMP=/tmp

function lso()
{
  if [ -t 0 ];then ls -alG "$@";else cat -;fi |
    awk '{t=$0;gsub(/\x1B\[[0-9;]*[mK]/,"");k=0;for(i=0;i<=8;i++)k+=((substr($1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(" %0o ",k);print t}'
}

function showbanner()
{
  local opt
  local t=1

  OPTIND=1 #reset index
  while getopts "t:" opt; do
    case $opt in
       t)
          shift $((OPTIND-1))
          shift $((OPTIND))
          t=$OPTARG
          ;;
       \?)
          echo "Invalid option: -$OPTARG" >&2
          exit 1
          ;;
       :)
          echo "Option -$OPTARG requires number of sec as an argument" >&2
          exit 1
    esac
  done
  OPTIND=1 #reset index again
  bannercmd=banner
  [[ -z $(which banner) ]] && bannercmd=echo
  watch -tn${t} "$@|xargs $bannercmd"
}
alias showclock='showbanner "date +%T"'

function ? {
  awk "BEGIN{ pi = 4.0*atan2(1.0,1.0); deg = pi/180.0; print $@ }"
}
  
# defining functions
#A function to pipe any command to less:
function so {
eval "$@" |less -I~
}

# crypting functions
function encrypt {
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
function decrypt {
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

# some cygwin related patches
# Terminal capabilities
if [ "$OSTYPE" = "cygwin" ]; then
  alias cs='cygstart'
  if [ -f ${HOME}/.termcap ]; then
    TERMCAP=$(< ${HOME}/.termcap)
    export TERMCAP
  fi
  if [ -x /usr/bin/tput ]; then
    LINES=$(tput lines)
    export LINES
    COLUMNS=$(tput cols)
    export COLUMNS 
  fi
fi

