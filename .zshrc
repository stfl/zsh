# {{{
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi
# }}}

############ environment {{{


# }}}
############ shell vaiables {{{

setopt RM_STAR_WAIT


# }}}
############ aliases {{{
#alias tnas="nc -zv 192.168.0.150 2049"
#alias mnas='wake nas; tnas; while [[ $? -ne 0 ]] { sleep 2; tnas }; sudo mount -a'
#alias snas='ssh nas sudo halt -p'
#alias mountrpi="sshfs -o idmap=user -o port=2223 stefan@192.168.0.151:/ /media/rpi/"
alias gvim='gvim --remote-tab'
alias tmux='TERM=xterm-256color tmux'
alias {zr,zreload}='. ~/.zshrc && . ~/.zprofile'
alias wget='wget --no-check-certificate'
alias vi='vim'
alias {ipa,ipp}='ip -br -c a'
command -v nvim &>/dev/null && alias vim='nvim'
alias ag="ag --hidden -p $HOME/.config/agignore"
alias rgf="rg -l '' -g" # only filename of file matching --glob (-g)

if command -v exa &>/dev/null; then
   alias ll='exa -lh@ --group-directories-first --git' 
   alias la='ll -a'
   alias lt='ll -T' # tree view
fi

alias killbg='kill ${${(v)jobstates##*:*:}%=*}' # kill all jobs in the background

# debian apt-get aliases
# {{{
alias sapt='sudo apt-get'
alias aup='sudo apt-get update'
alias {aupg,aug}='sudo apt-get upgrade' # multiple aliases -> IMPORTANT without space in {,}
alias {adupg,adg}='sudo apt-get dist-upgrade'
alias chup='sudo apt-get update && sudo apt-get upgrade'
alias chdup='sudo apt-get update && sudo apt-get dist-upgrade'
alias ai='sudo apt-get install'
alias ac='apt-cache'
alias deba='sudo apt-mark auto'

# alias find='noglob find -not -iwholename "*.svn" -path'
emulate bash -c 'runise() { \
   source /home/Xilinx/14.7/ISE_DS/settings64.sh; \
   ise; \
}'
# alias peerflix='peerflix --vlc'
#}}}

# enable quick dir and file navigation in shell
# alias j is set to quick cd in prezto
# alias v='fasd -f -e vim' # quick opening files with vim
# alias gv='fasd -f -e gvim' # quick opening files with vim
# alias jv='fasd -sif -e vim' # quick select for opening
# alias jgv='fasd -sif -e gvim' # quick select for opening
# alias jf='fasd -sif'     # interactive file selection

# }}}
############## keybinding {{{
bindkey -M viins 'jk' vi-cmd-mode
# bindkey -M viins "^K" history-substring-search-up
# bindkey -M viins "^J" history-substring-search-down
bindkey "^W" backward-kill-word # vi-backward-kill-word
bindkey -M vicmd "^W" vi-backward-kill-word
bindkey -M vicmd "gs" prepend-sudo
bindkey "^P" fzf-cd-widget
bindkey -M vicmd "ge" edit-command-line

# }}}
############## Functions {{{
# vcsh commit and push
# function vcsh_cp
# {
   # [[ $1 == "-h" ]] && echo "vcsh_cp <repo> <commit text>"
   # vcsh $1 commit -am $2
   # vcsh $1 push
# }

# write auto-commit post-commit hook to vcsh repo
vcsh_write_auto_commit()
{
   if [ ! -f ~/.config/vcsh/repo.d/$1.git/hooks/post-commit ] || [[ "$2" -eq "-f" ]]; then
      echo "#\!/bin/sh\necho "running post-commit hook"\ngit push origin master" \
         >| ~/.config/vcsh/repo.d/$1.git/hooks/post-commit
      chmod 700 ~/.config/vcsh/repo.d/$1.git/hooks/post-commit
   fi
}

function vcsh_up()
{
   setopt localtraps
   vcsh_up_forked $@ &
   child_pid=$!
   trap "echo exiting...; kill -- -$(ps -o pgid= $child_pid | grep -o '[0-9]*'); wait" INT
   wait
   zreload
}

# update all vcsh repos
function vcsh_up_forked
{
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


# Disable globbing on the remote path.
function scp_wrap {
  local -a args
  local i
  for i in "$@"; do case $i in
     (*:*) args+=($i) ;;
     (*) args+=(${~i}) ;;
  esac; done
  command scp ${=args} # enables forces white space splitting -> works when mutlipe input files are given - or globing
}

#files are .ssh/config and all in ~/.ssh/config.d
alias ssh='ssh_config_tmp; ssh' # -F ~/.ssh/config.tmp'
alias scp='ssh_config_tmp; noglob scp_wrap' # -F ~/.ssh/config.tmp'

ssh_config_tmp()
{
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

# telnet with hostname
telnet()
{
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

scp-local-hop()
{
   if [[ $# < 2 ]] || [[ $1 == "-h" ]]; then
      print usage: scp-local-hop user@remote user@remote2
   fi

   setopt localoptions noRM_STAR_WAIT

   local d=/tmp/local_hop
   local g=${d}/*(N)

   mkdir -p $d
   rm -rf ${~g}

   scp $1 $d
   scp ${~g} $2
  
   rm -rf ${~g}
}

imv()
{
  local src dst
  for src; do
    [[ -e $src ]] || { print -u2 "$src does not exist"; continue }
    dst=$src
    vared dst
    [[ $src != $dst ]] && mkdir -p $dst:h && mv -n $src $dst
  done
}

# function preexec {
  # # emulate -L zsh
  # local -a cmd; cmd=(${(z)1})
  # title $cmd[1]:t "$cmd[2,-1]"
# }

# comparte versions - requires sort -V option!
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

# run mr in home dir and colorize output
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

# fzf functions {{{
# https://github.com/junegunn/fzf/wiki/examples
if command -v ag &>/dev/null; then
   export FZF_DEFAULT_COMMAND='ag --hidden -g ""'
   export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

   _fzf_compgen_path() {
      ag -g "" "$1"
   }
fi
export FZF_DEFAULT_OPTS="--reverse --inline-info"
export FZF_TMUX_HEIGHT="30%"

command -v fasd &>/dev/null && eval "$(fasd --init auto)"

j() {
  local dir
  dir="$(fasd -Rdl "$1" | fzf-tmux -1 -0 --no-sort +m)" \
     && cd "${dir}" \
     || return 1
}
v() {
   local file
   file="$(fasd -Rfl "$1" | fzf-tmux -1 -0 --no-sort -m)" \
      && vim -p ${=file} \
      || return 1
}
jj() {
   local dest
   dest=$(dirs | sed "s/ /\n/g" | fzf-tmux) \
      && cd ${~dest} \
      || return 1
   # requires ~ to remove surrounding ''
}

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fe() {
   local file
   # use multi select with <TAB>
   file=$(fzf-tmux --query="$1" --select-1 --exit-0 -m) \
      && vim -p ${=file} \
      || return 1
}

# fd - cd to selected directory
fd() {
   local dir
   dir=$(find ${1:-.} -path '*/\.*' -prune \
      -o -type d -print 2> /dev/null | fzf-tmux +m) \
      && cd "$dir" \
      || return 1
}

# fda - including hidden directories
fda() {
   local dir
   dir=$(find ${1:-.} -type d 2> /dev/null | fzf-tmux +m) \
      && cd "$dir" \
      || return 1
}

# ftags - search ctags
ftags() {
   local line
   [ -e tags ] && line=$(
      awk 'BEGIN { FS="\t" } !/^!/ {print toupper($4)"\t"$1"\t"$2"\t"$3}' tags |
      cut -c1-80 | fzf --nth=1,2
   ) && $EDITOR $(cut -f3 <<< "$line") -c "set nocst" -c "silent tag $(cut -f2 <<< "$line")" \
      || return 1
}

# fshow - git commit browser
# Ctrl - S : toggle-sort
# Ctrl - M : show
fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}
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

source ~/.zprofile
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh



