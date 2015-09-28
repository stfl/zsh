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

# aliases
# {{{
#alias tnas="nc -zv 192.168.0.150 2049"
#alias mnas='wake nas; tnas; while [[ $? -ne 0 ]] { sleep 2; tnas }; sudo mount -a'
#alias snas='ssh nas sudo halt -p'
#alias mountrpi="sshfs -o idmap=user -o port=2223 stefan@192.168.0.151:/ /media/rpi/"
alias gvim='gvim --remote-tab'
alias tmux='TERM=xterm-256color tmux'
alias zreload='. ~/.zshrc && . ~/.zprofile'

#files are .ssh/config and all in ~/.ssh/config.d
alias ssh='ssh -F <(cat ~/.ssh/config ~/.ssh/config.d/* 2> /dev/null)'
alias scp='noglob scp_wrap -F <(cat ~/.ssh/config ~/.ssh/config.d/* 2> /dev/null)'

# debian apt-get aliases
# {{{
alias sapt='sudo apt-get'
alias aup='sudo apt-get update'
alias {aupg,aug}='sudo apt-get upgrade' # multiple aliases -> IMPORTANT without space in {,}
alias {adupg,adg}='sudo apt-get dist-upgrade'
alias chup='sudo apt-get update && sudo apt-get upgrade'
alias ai='sudo apt-get install'
alias ac='apt-cache'

# alias find='noglob find -not -iwholename "*.svn" -path'
emulate bash -c 'runise() { source /home/Xilinx/14.7/ISE_DS/settings64.sh; ise; }'
alias peerflix='peerflix --vlc'
#}}}

# enable quick dir and file navigation in shell
# eval "$(fasd --init auto)"
# alias j is set to quick cd in prezto
alias v='fasd -f -e vim' # quick opening files with vim
alias gv='fasd -f -e gvim' # quick opening files with vim
alias jv='fasd -sif -e vim' # quick select for opening
alias jgv='fasd -sif -e gvim' # quick select for opening
alias jf='fasd -sif'     # interactive file selection

# }}}

############## keybinding
# {{{
bindkey -M emacs "^H" emacs-backward-word
bindkey -M emacs "^L" emacs-forward-word
bindkey -M emacs "^K" history-substring-search-up
bindkey -M emacs "^J" history-substring-search-down
# }}}

############## Functions
# {{{
# vcsh commit and push
function vcsh_cp
{
   [[ $1 == "-h" ]] && echo "vcsh_cp <repo> <commit text>"
   vcsh $1 commit -am $2
   vcsh $1 push
}

# Disable globbing on the remote path.
function scp_wrap {
  local -a args
  local i
  for i in "$@"; do case $i in
    (*:*) args+=($i) ;;
    (*) args+=(${~i}) ;;
  esac; done
  command scp "${(@)args}"
}

# automatically set title in screen and xterm - not working
# function title {
  # if [[ $TERM == "screen" ]]; then
    # # Use these two for GNU Screen:
    # print -nR $'\033k'$1$'\033'\\

    # print -nR $'\033]0;'$2$'\a'
  # elif [[ $TERM == "xterm" || $TERM == "rxvt" ]]; then
    # # Use this one instead for XTerms: # print -nR $'\033]0;'$*$'\a' # fi # } # function precmd { # title zsh "$PWD"
# }

# function preexec {
  # # emulate -L zsh
  # local -a cmd; cmd=(${(z)1})
  # title $cmd[1]:t "$cmd[2,-1]"
# }


# }}}

# add hosts completion for .ssh/config.d/ files
zstyle -s ':completion:*:hosts' hosts _ssh_config
[[ -d ~/.ssh/config.d ]] && _ssh_config+=($(cat ~/.ssh/config.d/* | sed -ne 's/Host[=\t ]//Ip'))
zstyle ':completion:*:hosts' hosts $_ssh_config


source ~/.zprofile
