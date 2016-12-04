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
export PAGER=less
export BANNER="echo"
[[ -n "$(which banner)" ]] && export BANNER="banner"
[[ -n "$(which toilet)" ]] && export BANNER="toilet -f mono9.tlf"
# setting the temp directory for vim
[ -z $TEMP ] && export TEMP=/tmp


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
alias feh='feh -g 800x600 -d -.'
alias ne='sed "s,\x1B\[[0-9;]*[a-zA-Z],,g"'
alias c='printf "\33[2J"'
alias ss='bc64=( {a..z} {A..Z} {0..9} + / = );c;while true; do echo -ne "\033[$((1+RANDOM%LINES));$((1+RANDOM%COLUMNS))H\033[$((RANDOM%2));3$((RANDOM%8))m${bc64[$((RANDOM%${#bc64[@]}))]}"; sleep 0.1 ; done'
alias p4='unset PWD; p4 '
alias ff='wget randomfunfacts.com -O - 2>/dev/null | grep \<strong\> | sed "s;^.*<i>\(.*\)</i>.*$;\1;"'
alias genpass='read -s tmppass; echo -n "$tmppass->"; echo $tmppass | md5sum | base64 | cut -c -16; unset tmppass'
alias 2edit='xsel -b;n=pipe$RANDOM;xdotool exec --terminator -- mousepad $n -- search --sync --onlyvisible --name $n key --window %1 ctrl+v ctrl+Home'
alias 2win='xsel -b;n=pipe$RANDOM;xdotool exec --terminator -- subl $n -- search --sync --onlyvisible --name $n key --window %1 ctrl+v ctrl+Home'
alias readpass='echo -n $(read -s passwd_;echo -n $passwd_)'
alias cdh='cd ~'
alias top10='ps aux --sort -rss | head'
alias traf='netstat -np | grep -v ^unix'
alias why='apt-cache rdepends --installed'

# git shortcuts
alias gc='git checkout'
alias gcb='git checkout -branch'
alias ga='git add'
alias gap='git add -p'
alias gs='git status'
alias gl='git log'
alias gb='git branch'
alias gd='git diff'
alias gcm='git commit -m'

#coloring some programs using grc (check /usr/share/grc)
alias hexdump='grc hexdump'
alias ps='grc ps -A'
alias ping='grc ping'
alias ifconfig='grc ifconfig'
alias mount='grc mount'
alias df='grc df -Th'
alias netstat='grc netstat'
alias gcc='grc gcc'
alias nmap='grc nmap'
alias cat='grc cat'
alias diff='grc diff'
alias ls='grc ls -X -hF --color=yes --group-directories-first'
alias tail='grc tail'

alias hl='highlight --style olive -O xterm256'

alias showtemp='showbanner -t 20 '\''echo "temp: "$(ssh root@buffalo.lan /mnt/sd/bin/readavrstick)°'\'''
alias showclock='showbanner "date +%T"'
alias timer='export ts=$(date +%s);p='\''date -u -d @"$(($(date +%s)-$ts))" +"%H.%M.%S"'\'';showbanner "$p";eval "$p"'
#alias timer='cmd=echo;[[ -n "$BANNER" [] && cmd="$BANNER";export cmd;export ts=$(date +%s);p='\''$(date -u -d @"$(($(date +%s)-$ts))" +"%H.%M.%S")'\'';watch --color -n 1 -t $cmd $p;eval "echo $p"'

 
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

# generated prompt line
source ${HOME}/bin/shellprompt.sh
# custom functions
source ${HOME}/bin/shellfunctions.sh
# colors
source ${HOME}/bin/shellcolors.sh

