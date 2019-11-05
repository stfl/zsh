# {{{ Executes commands at the start of an interactive session.
#
# Source Prezto.
# if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
#   source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
# fi

# zmodload zsh/zprof

ZPLUG_SUDO_PASSWORD=
ZPLUG_PROTOCOL=ssh

export ZPLUG_HOME=$HOME/.config/zplug

if [[ ! -d $ZPLUG_HOME ]]; then
  git clone https://github.com/zplug/zplug $ZPLUG_HOME
  source $ZPLUG_HOME/init.zsh && zplug update --self
fi
source $ZPLUG_HOME/init.zsh
source $HOME/.config/zsh/zplugins.zsh

# }}}

############ environment {{{

#private bitbucket
export GITURL="git@bitbucket.org:stfl_priv"


# }}}
############ aliases {{{
#alias tnas="nc -zv 192.168.0.150 2049"
#alias mnas='wake nas; tnas; while [[ $? -ne 0 ]] { sleep 2; tnas }; sudo mount -a'
#alias snas='ssh nas sudo halt -p'
#alias mountrpi="sshfs -o idmap=user -o port=2223 stefan@192.168.0.151:/ /media/rpi/"
alias gvim='gvim --remote-tab'
# alias tmux='TERM=xterm-256color tmux'
alias {zr,zreload}='. ~/.zshrc && . ~/.zprofile'
alias wget='wget --no-check-certificate'
alias {py,py3}='python3'
alias py2='python2'
alias x='exit'
alias {ipa,ipp}='ip -br -c a'
alias vi='vim'
command -v nvim &>/dev/null && alias vim='nvim'
alias ag="ag --hidden -p $HOME/.config/agignore"
# alias rgf="rg --hidden --files -g"  # only filenames --glob (-g)
alias killbg='kill ${${(v)jobstates##*:*:}%=*}' # kill all jobs in the background
alias path='echo ${PATH//:/\\n}'
command -v fd &>/dev/null || alias fd='find'  # use regular find if fd is not installed


if command -v exa &>/dev/null; then
   alias ll='exa -lh --group-directories-first' # --git' 
   alias la='ll -a'
   alias lt='ll -T' # tree view
fi

alias p='pacui'

# debian apt-get aliases
# {{{
command -v apt-fast &>/dev/null && alias a='sudo apt-fast' || alias a='sudo apt'
# alias a='myapt'
alias aup='a update'
alias {aupg,aug}='a upgrade -y' # multiple aliases -> IMPORTANT without space in {,}
alias {adupg,adg}='a dist-upgrade -y'
alias chup='a update && a upgrade -y'
alias chdup='a update && a dist-upgrade -y'
alias ai='a install'
alias ac='apt-cache'
alias deba='sudo apt-mark auto'

akey(){
   gpg --keyserver ${2-pgp.mit.edu} --recv-keys $1
   gpg --armor --export $1 | sudo apt-key add -
}

# alias find='noglob find -not -iwholename "*.svn" -path'
emulate bash -c 'runise() { \
   source /home/Xilinx/14.7/ISE_DS/settings64.sh; \
   ise; \
}'
# alias peerflix='peerflix --vlc'
#}}}

# }}}
############## keybinding | mappings {{{
# vi keybindings
# bindkey -v
bindkey -M viins 'jk' vi-cmd-mode
# bindkey -M viins "^K" history-substring-search-up
# bindkey -M viins "^J" history-substring-search-down
bindkey "^W" backward-kill-word # vi-backward-kill-word
bindkey -M vicmd "^W" vi-backward-kill-word
bindkey -M vicmd "gs" prepend-sudo
bindkey -M vicmd "ge" edit-command-line


# }}}
############## Functions {{{
# update all vcsh repos{{{
function vcsh_up_forked {
   echo "vcsh local status:"
   vcsh status
   if [[ x"-v" == x"$1" ]]; then
      shift
      debug=0
      set -x
   fi
   vermin 1.7.11 `git --version | awk '{print $3}'`
   stree=$?
   [[ 0 != $stree ]] && echo "git doesn't support stree!"
   # vcsh pull
   for repo in $(vcsh list); do
      (  cd ${HOME}
         vcsh $repo pull
         local ret=$?
         if [[ 0 == $stree ]]; then
            for st in $(vcsh $repo stree list | awk '{print $2}'); do
               vcsh $repo stree pull $st
               let "ret+=$?"
            done
         fi
         if [[ "$ret" -gt "0" ]]; then
            echo -e "$(color red)$repo failed$(color)"
         else
            echo -e "$(color green)$repo successfull$(color)"
         fi
         vcsh write-gitignore $repo
      ) & # make the whole thing parallel !!!
      vcsh $repo config branch.master.remote origin
      vcsh $repo config branch.master.merge refs/heads/master
      vcsh_write_auto_commit $repo
   done
   wait
   [[ 0 == $debug ]] && set +x
}

# }}}
# Disable globbing on the remote path.{{{
function scp_wrap {
  local -a args
  local i
  for i in "$@"; do case $i in
     (*:*) args+=($i) ;;
     (*) args+=(${~i}) ;;
  esac; done
  command scp ${=args} # enables forces white space splitting -> works when mutlipe input files are given - or globing
}

# }}}

ssh-git-setup() {
   target=$1
   identity=${2:-"~/.ssh/id_rsa_me_bb"}
   ssh-copy-id -i $identity $target &>/dev/null
   ssh $target -A -T << EOF
      if [[ -f ${identity}.pub ]]; then
         echo "public key already exists"
      else
         mkdir ~/.ssh 2>/dev/null
         ssh-add -L | grep ${identity:s/~/} > ${identity}.pub
         echo -e "Host bitbucket.org
            IdentityFile ${identity}" >> ~/.ssh/config;
         git config --global user.name 'Stefan Lendl'
         git config --global user.email 'sll@mission-embedded.com'
      fi
EOF
}

# .ssh/config.d{{{
#files are .ssh/config and all in ~/.ssh/config.d
alias ssh='ssh_config_tmp; ssh' # -F ~/.ssh/config.tmp'
# alias scp='ssh_config_tmp; noglob scp_wrap' # -F ~/.ssh/config.tmp'
alias scp='ssh_config_tmp; scp' # -F ~/.ssh/config.tmp'

ssh_config_tmp() {
   setopt localoptions nonomatch null_glob
   rm -f ${HOME}/.ssh/config
   cat > ${HOME}/.ssh/config <<EOF
# DO NOT EDIT THIS FILE!!!
# IT WILL BE OVERWRITTEN
#
# Place your config in ${HOME}/.ssh/config.d/

EOF
   # cat ~/.ssh/config 2>/dev/null >> ~/.ssh/config.tmp
   cat ~/.ssh/config.d/* 2>/dev/null >> ~/.ssh/config
   chmod 400 ~/.ssh/config
   # cat ~/.ssh/config.tmp
   # rm -f ~/.ssh/config.tmp
}

# ssh-copy-id()
# {
#    ssh $1 'mkdir ~/.ssh 2>/dev/null;
#            cat >> ~/.ssh/authorized_keys' < ~/.ssh/id_*.pub
# }

# telnet with hostname {{{
telnet() {
   avail_hosts=$(cat ~/.ssh/config |\
      sed -ne 's/Host[=\t ]//Ip' |\
      sed -ne '/^[^#]/p' |\
      tr '\n' ' ' )
   avail_array=(${=avail_hosts})                                     # make array
   if [[ ${avail_array[(i)${1}]} > $#avail_array ]]; then            # not in array
      command telnet $@
   else
      echo lookup $1 in ssh hosts
      connect=$1
      shift
      local fifo=/tmp/hosts
      mkfifo $fifo
      exec 6<>$fifo
      cat ~/.ssh/config |\
         sed -ne 's/Host[=\t ]//Ip' -ne 's/hostname[=\t ]//Ip' |\
         sed -ne '/^[ \t]*#/!p' >&6
      while true; do                                              # we already know it's in there
         read host <&6
         read ip <&6
         ha=(${=host})
         if [[ ${ha[(i)${connect}]} < $#ha ]]; then
            echo found $ip
            connect=$ip
            break
         fi
      done
      exec 6<&-                                                      # closing the fd
      rm -f $fifo
      command telnet $connect $@
   fi
}

# }}}
# }}}
imv()# {{{
{
  local src dst
  for src; do
    [[ -e $src ]] || { print -u2 "$src does not exist"; continue }
    dst=$src
    vared dst
    [[ $src != $dst ]] && mkdir -p $dst:h && mv -n $src $dst
  done
}

# }}}
# compare versions{{{
# requires sort -V option!
# verlte 2.5.7 2.5.6 && echo "yes" || echo "no" # no
# verlt 2.4.8 2.4.10 && echo "yes" || echo "no" # yes
vermin verlte()
{
   if [[ "$#" == "0" ]] || [[ x"-h" == x"$1" ]]; then
      echo "$0 2.5.7 2.5.6 && echo yes || echo no # (<= no)"
      echo "[ \$1 -le \$2 ]"
      echo "$0 \$min_required \$current"
      return
   fi
   [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
   return $?
}
verlt()
{
   if [[ "$#" == "0" ]] || [[ x"-h" == x"$1" ]]; then
      echo "$0 2.4.8 2.4.10 && echo yes || echo no # (<= yes)"
      echo "[ \$1 -lt \$2 ]"
      echo "$0 \$last_version \$current"
      return
   fi
   [ "$1" = "$2" ] && return 1 || verlte $1 $2
   return $?
}

# print full file names
lf()
{
   if [[ "$#" == "0" ]]; then
      # current dir
      local dir="$PWD/*"
   elif [[ "$#" == "1" ]]; then
      if [[ -d $1 ]]; then
         # dir target
         local dir=${PWD}/${~@}/*
      else
         # one file target
         local dir=$PWD/$1
      fi
   fi
   ll -d $~dir
}

# }}}
# run mr in home dir and colorize output {{{
mr()
{
   if [[ $1 == up ]]; then
      (cd ~
      GREP_COLORS="mc=01;31"
      command mr -j 5 up 2>&1 | egrep --colour "\bfailed\b|$"
      )
   else
      command mr $@
   fi
}

# }}}

# tar() {
  # tar -cSf - $1 -I lbzip2 | pv -p --timer --rate --bytes --size `sudo du -sb rootfs | cut -f1` >| /tmp/test.tar.bz2
# }

get_latest_release_github() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")'
}

# install_latest_release_github() {
#   get_latest_release_github $1
# }

source ~/.config/zsh/fzf.zsh
# source ~/.config/zsh/yocto.zsh

# }}}
# }}}
############## completion {{{
# add hosts completion for .ssh/config.d/ files
# zstyle -s ':completion:*:hosts' hosts _ssh_config
ssh_config_tmp # make the ssh_config.tmp once
# [[ -e ~/.ssh/config.tmp ]] && \
#    _ssh_config=($(cat ~/.ssh/config.tmp | sed -ne 's/Host[=\t ]//Ip' | sed -ne '/^[^#]/p'))
# zstyle ':completion:*:hosts' hosts $_ssh_config

#vim tags
function _get_tags {
  [ -f ./tags ] || return
  local cur
  read -l cur
  echo $(echo $(awk -v ORS=" "  "/^${cur}/ { print \$1 }" tags))
}
compctl -x 'C[-1,-t]' -K _get_tags -- vim
#end vim tags

autoload -Uz compinit && compinit -i
autoload bashcompinit && bashcompinit

[ -f /opt/google-cloud-sdk/completion.zsh.inc ] && source /opt/google-cloud-sdk/completion.zsh.inc

source ${HOME}/.config/zsh/bash_completion/gstreamer-completion

# }}}


# }}}

source ~/.zprofile

# source frq specifics if present
[[ -f ~/.zprofile.frq ]] && source ~/.zprofile.frq


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
