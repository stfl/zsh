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

############ vaiables {{{

# }}}

############ aliases {{{
#alias tnas="nc -zv 192.168.0.150 2049"
#alias mnas='wake nas; tnas; while [[ $? -ne 0 ]] { sleep 2; tnas }; sudo mount -a'
#alias snas='ssh nas sudo halt -p'
#alias mountrpi="sshfs -o idmap=user -o port=2223 stefan@192.168.0.151:/ /media/rpi/"
alias gvim='gvim --remote-tab'
alias tmux='TERM=xterm-256color tmux'
alias zreload='. ~/.zshrc && . ~/.zprofile'
alias wget='wget --no-check-certificate'
alias vi='vim'
command -v nvim &>/dev/null && alias vim='nvim'

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
# bindkey -M emacs "^H" emacs-backward-word
# bindkey -M emacs "^L" emacs-forward-word
# bindkey -M emacs "^K" history-substring-search-up
# bindkey -M emacs "^J" history-substring-search-down
# bindkey -M emacs 'jk' vi-cmd-mode

bindkey -M viins 'jk' vi-cmd-mode
bindkey -M viins "^K" history-substring-search-up
bindkey -M viins "^J" history-substring-search-down
bindkey "^W" backward-kill-word # vi-backward-kill-word
# bindkey "^X^S" prepend-sudo
bindkey "^P" fzf-cd-widget
# bindkey "^P" fzf-file-widget
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
vcsh_write_auto_commit() {
   if [ ! -f ~/.config/vcsh/repo.d/$1.git/hooks/post-commit ] || [[ "$2" -eq "-f" ]]; then
      echo "#\!/bin/sh\necho "running post-commit hook"\ngit push origin master" \
         >| ~/.config/vcsh/repo.d/$1.git/hooks/post-commit
      chmod 700 ~/.config/vcsh/repo.d/$1.git/hooks/post-commit
   fi
}

# update all vcsh repos
function vcsh_up {
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
      (  vcsh $repo pull
         if [[ 0 == $stree ]]; then
            for st in $(vcsh $repo stree list | awk '{print $2}'); do
               vcsh $repo stree pull $st
            done
         fi
         vcsh write-gitignore $repo
      ) &
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
alias ssh='ssh_config_tmp; ssh -F ~/.ssh/config.tmp'
alias scp='ssh_config_tmp; noglob scp_wrap -F ~/.ssh/config.tmp'

ssh_config_tmp() {
   setopt localoptions nonomatch null_glob
   cat ~/.ssh/config 2>/dev/null >| ~/.ssh/config.tmp
   cat ~/.ssh/config.d/* 2>/dev/null >> ~/.ssh/config.tmp
   # cat ~/.ssh/config.tmp
   # rm -f ~/.ssh/config.tmp
}

ssh-copy-id() {
   ssh $1 'mkdir ~/.ssh; cat >> ~/.ssh/authorized_keys' < ~/.ssh/id_*.pub
}

imv() {
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
vermin verlte() {
   if [[ "$#" == "0" ]] || [[ x"-h" == x"$1" ]]; then
      echo "$0 2.5.7 2.5.6 && echo yes || echo no # (<= no)"
      echo "[ \$1 -le \$2 ]"
      echo "$0 \$min_required \$current"
      return
   fi
   [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
   return $?
}
verlt() {
   if [[ "$#" == "0" ]] || [[ x"-h" == x"$1" ]]; then
      echo "$0 2.4.8 2.4.10 && echo yes || echo no # (<= yes)"
      echo "[ \$1 -lt \$2 ]"
      echo "$0 \$last_version \$current"
      return
   fi
   [ "$1" = "$2" ] && return 1 || verlte $1 $2
   return $?
}

# fzf functions {{{
# https://github.com/junegunn/fzf/wiki/examples

command -v ag &>/dev/null && export FZF_DEFAULT_COMMAND='ag -g ""'

z() {
  local dir
  dir="$(fasd -Rdl "$1" | fzf-tmux -1 -0 --no-sort +m)" && cd "${dir}" || return 1
}
v() {
   local file
   file="$(fasd -Rfl "$1" | fzf-tmux -1 -0 --no-sort +m)" && vim "${file}" || return 1
}

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fe() {
  local file
  file=$(fzf-tmux --query="$1" --select-1 --exit-0)
  [ -n "$file" ] && ${EDITOR:-vim} "$file"
}

# fd - cd to selected directory
fd() {
  local dir
  [[ $# == 0 ]] && 1="."
  dir=$(find ${1:-*} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf-tmux +m) && cd "$dir"
}

# fda - including hidden directories
fda() {
  local dir
  [[ $# == 0 ]] && 1="."
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf-tmux +m) && cd "$dir"
}
# }}}
# }}}

############## completion {{{
# add hosts completion for .ssh/config.d/ files
# zstyle -s ':completion:*:hosts' hosts _ssh_config
ssh_config_tmp # make the ssh_config.tmp once
[[ -e ~/.ssh/config.tmp ]] &&  _ssh_config+=($(cat ~/.ssh/config.tmp | sed -ne 's/Host[=\t ]//Ip'))
zstyle ':completion:*:hosts' hosts $_ssh_config

#vim tags
function _get_tags {
  [ -f ./tags ] || return
  local cur
  read -l cur
  echo $(echo $(awk -v ORS=" "  "/^${cur}/ { print \$1 }" tags))
}
compctl -x 'C[-1,-t]' -K _get_tags -- vim
#end vim tags

# }}}

source ~/.zprofile
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
