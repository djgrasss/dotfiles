# Don't wait for job termination notification
set -o notify
shopt -s dotglob

# Ignore some controlling instructions
export HISTIGNORE="[   ]*:&:bg:fg:exit:ls:la:ll:l:ps:df:vim:vi:man*:info*:exit:dmesg:ifconfig:route:"
export HISTSIZE=-1     # unlimited
export HISTFILESIZE=-1 # unlimited
export HISTFILE=~/.bash_eternal_history
export EDITOR=vi

# aliases
alias less='less -r'                          # raw control characters
alias grep='grep --color'                     # show differences in colour

# Some shortcuts for different directory listings
alias ls='ls -X -hF --color=tty'              # classify files in colour
alias dir='ls --color=auto --format=vertical'
alias vdir='ls --color=auto --format=long'
alias ll='ls -lA'                             # long list
alias la='ls -A'                              # all but . and ..
alias l='ls -CF'                              #
alias ps='ps -A'                              #
alias rm='trash-put'                          # safe rm

# my shortcuts
alias cs='cygstart'
alias c='printf "\33[2J"'
alias ss='bc64=( {a..z} {A..Z} {0..9} + / = );c;while true; do echo -ne "\033[$((1+RANDOM%LINES));$((1+RANDOM%COLUMNS))H\033[$((RANDOM%2));3$((RANDOM%8))m${bc64[$((RANDOM%${#bc64[@]}))]}"; sleep 0.1 ; done'
alias p4='unset PWD; p4 '
alias ff='wget randomfunfacts.com -O - 2>/dev/null | grep \<strong\> | sed "s;^.*<i>\(.*\)</i>.*$;\1;"'
alias genpass='read -s tmppass; echo -n "$tmppass->"; echo $tmppass | md5sum | base64 | cut -c -16; unset tmppass'
alias 2edit='xsel -b;n=pipe$RANDOM;xdotool exec --terminator -- mousepad $n -- search --sync --onlyvisible --name $n key --window %1 ctrl+v'
alias 2win='xsel -b;n=pipe$RANDOM;xdotool exec --terminator -- subl $n -- search --sync --onlyvisible --name $n key --window %1 ctrl+v'
alias readpass='echo -n $(read -s passwd_;echo -n $passwd_)'
alias cdh='cd ~'
alias timer='export ts=$(date +%s);p='\''$(date -u -d @"$(($(date +%s)-$ts))" +"%H.%M.%S")'\'';watch -n 1 -t banner $p;eval "echo $p"'
alias gc='git checkout'
alias gcb='git checkout -branch'
alias ga='git add'
alias gs='git status'
alias gl='git log'
alias gb='git branch'
alias gd='git diff'


# setting the temp directory for vim
[ -z $TEMP ] && export TEMP=/tmp

function lso()
{
  # interactive
  if [ -t 0 ]; then
    ls -alG $1 | awk '{k=0;for(i=0;i<=8;i++)k+=((substr($1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(" %0o ",k);print}'
  else
    cat - | awk '{k=0;for(i=0;i<=8;i++)k+=((substr($1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(" %0o ",k);print}'
  fi
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
  watch -tn${t} "$@|xargs banner"
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

