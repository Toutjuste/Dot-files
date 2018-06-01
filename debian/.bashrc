################################
## Custom ~/.bashrc file
################################

#Include colors definition file
if [ -f ~/.colors ]; then
    . ~/.colors
fi

#Include server color config file
if [ -f ~/.prompt_color ]; then
    . ~/.prompt_color
else
    #File not exists, set value to 2 (yellow)
    PROMPT_COLOR=2
fi

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=2000
HISTFILESIZE=5000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    #Check the specified color
    # 1 --> blue (for server)
    # 2 --> yellow
    # 3 --> green

    if [ $PROMPT_COLOR -eq 1 ]; then
        #Blue based colors (for server)
        PS1="${debian_chroot:+($debian_chroot)}$E_BBlu[\u$E_BCya@$E_BBlu\h] $E_Cya\$ \w $E_BBlu>$E_RCol "
    else
        if [ $PROMPT_COLOR -eq 3 ]; then
            #Green based colors
	        PS1="${debian_chroot:+($debian_chroot)}$E_BGre[\u$E_BPur@$E_BGre\h] $E_Gre\$ \w $E_BGre>$E_RCol "
        else
            #Yellow based colors (default set to 2)
            PS1="${debian_chroot:+($debian_chroot)}$E_BYel[\u$E_BRed@$E_BYel\h] $E_Yel\$ \w $E_BYel>$E_RCol "
        fi
    fi
else
    #Uncolored prompt
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt PROMPT_COLOR

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    #Default title
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#Clean path
export PATH=/opt/crosstool-ng-1.21.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games

#################################
#  CUSTOM
#################################

#Add Qt path config file
if [ -f ~/.qt_path ]; then
    . ~/.qt_path
fi

#############
# FUNCTIONS
#

# Easy extract
extract () {
  if [ -f $1 ] ; then
      case $1 in
          *.tar.bz2)   tar xvjf $1    ;;
          *.tar.gz)    tar xvzf $1    ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       rar x $1       ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xvf $1     ;;
          *.tbz2)      tar xvjf $1    ;;
          *.tgz)       tar xvzf $1    ;;
          *.zip)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *)           echo "don't know how to extract '$1'..." ;;
      esac
  else
      echo "'$1' is not a valid file!"
  fi
}

# Create a .vmdk file (disk drive format for VirtualBox), linked to
# the physical disk specified in second parameter. Need root (to be in /var/root/.bashrc too)

vdisk()
{
	if [ $# == 2 ]
	then
		VBoxManage internalcommands createrawvmdk -filename "$1.vmdk" -rawdisk /dev/$2
		echo "Please check unmounting the disk $2."
	else
		echo "Usage: vdisk <filename> <disk_id>"
	fi
}

# Function to be alerted when loooong process is running.
# Pass it the PID and the quoted-text as arguments.

alert_end_pid()
{
    if [ $# == 2 ]
    then
        (while kill -0 "$1" 2> "/dev/null"; do sleep 1; done) && say "$2" &
    else
        echo "Usage: alert_end_pid <PID> <message>"
        echo "(please check your sound volume)"
    fi
}

#Defined here because it can be used in welcome() function
#Month calendar with current day in red
alias c='var=$(cal); echo "${var/$(date +%-d)/$(echo -e "\033[1;31m$(date +%-d)\033[0m")}"'

#Welcome msg
welcome() {
  if [ -f ~/.welcome_msg ]; then
      . ~/.welcome_msg
  else
      clear
      echo -ne "Up time:";uptime | awk /'up/'
      echo ""
  fi
}

############
# ALIASES
#

#Alias to reload the bashrc file
alias reload='source ~/.bashrc'

#Dir shortcuts
alias home='cd ~/'
alias documents='cd ~/Documents'
alias downloads='cd ~/Téléchargements'
alias images='cd ~/Images'
alias code='cd ~/code'
alias ..='cd ..'

#Apt-get
alias install='sudo apt-get install'
alias update='sudo apt-get update'
alias upgrade='sudo apt-get upgrade'
alias remove='sudo apt-get remove'
alias autoremove='sudo apt-get autoremove'
alias autoclean='sudo apt-get autoclean'

#Update the distribution
alias update-all='sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade && sudo apt-get autoclean && sudo apt-get clean && sudo apt-get autoremove'

#Misc
alias nano='nano -W -m'
alias edit='nano'
alias wget='wget -c'
alias path='echo -e ${PATH//:/\\n}'
alias trash="rm -fr ~/.Trash"
alias lol='figlet -l "Lol"'

#Set default editor
export EDITOR="nano"

#Accentued characters
bind 'set convert-meta off'

######################
# STARTUP COMMANDS
#

#Welcome msg at startup
welcome

