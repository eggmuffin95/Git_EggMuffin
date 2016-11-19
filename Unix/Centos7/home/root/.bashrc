# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "`dircolors`"
# alias ls='ls $LS_OPTIONS'
# alias ll='ls $LS_OPTIONS -l'
# alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
# ~/.bashrc: executed by bash(1) for non-login shells.

alias l='ls -AlF --color=auto'
alias ll='ls -alF --color=auto'
alias resweb='service apache2 restart && service apache2 status --color=auto'
export TERM=xterm-color
alias upgradedb='/usr/libexec/locate.updatedb'
alias grep='grep --color=always'
alias egrep='egrep --color=always'
# Prompt
RED="\[\033[0;31m\]"
GREEN="\[\033[32m\]"
BROWN="\[\033[33m\]"
WHITE="\[\033[00m\]"
FLASHY="\e[32;1m\]"
PS1="$GREEN\h$WHITE-$RED\$(date +%H:%M)$WHITE-$GREEN\u$WHITE-$BROWN\$(ifconfig eno16777736 | grep \"inet\" | awk ' NR==1 {print \$2}'| tr \"\\012\" \"-\")$RED\w$WHITE# "
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
export EDITOR=vi
