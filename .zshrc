#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

#alias tnas="nc -zv 192.168.0.150 2049"
#alias mnas='wake nas; tnas; while [[ $? -ne 0 ]] { sleep 2; tnas }; sudo mount -a'
#alias snas='ssh nas sudo halt -p'
#alias mountrpi="sshfs -o idmap=user -o port=2223 stefan@192.168.0.151:/ /media/rpi/"
alias gvim='gvim --remote-tab'
alias tmux='TERM=xterm-256color tmux'
alias zreload='. ~/.zshrc && . ~/.zprofile'
alias peerflix='peerflix --vlc'

# debian apt-get aliases
alias sapt='sudo apt-get'
alias aup='sudo apt-get update'
alias {aupg,aug}='sudo apt-get upgrade' # multiple aliases -> IMPORTANT without space in {,}
alias {adupg,adg}='sudo apt-get dist-upgrade'
alias chup='sudo apt-get update && sudo apt-get upgrade'


# alias find='noglob find -not -iwholename "*.svn" -path'
emulate bash -c 'runise() { source /home/Xilinx/14.7/ISE_DS/settings64.sh; ise; }'

############## keybinding

bindkey -M emacs "^H" emacs-backward-word
bindkey -M emacs "^L" emacs-forward-word
bindkey -M emacs "^K" history-substring-search-up
bindkey -M emacs "^J" history-substring-search-down

############## Functions
# vcsh commit and push
function vcsh_cp {
   [[ $1 == "-h" ]] && echo "vcsh_cp <repo> <commit text>"
   vcsh $1 commit -am $2
   vcsh $1 push
}

# Disable globbing on the remote path.
alias scp='noglob scp_wrap'
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

# enable quick dir and file navigation in shell
# eval "$(fasd --init auto)"
# alias j is set to quick cd in prezto
alias v='fasd -f -e vim' # quick opening files with vim
alias gv='fasd -f -e gvim' # quick opening files with vim
alias jv='fasd -sif -e vim' # quick select for opening
alias jgv='fasd -sif -e gvim' # quick select for opening
alias jf='fasd -sif'     # interactive file selection

source ~/.zprofile