#
# Executes commands at login pre-zshrc.
#

#
# Browser
#

#
# Editors
#

if command -v nvim &>/dev/null; then
   export EDITOR='nvim'
   export VISUAL='nvim'
else
   export EDITOR='vim'
   export VISUAL='vim'
fi
export PAGER='less' # 'vimpager'
alias less=$PAGER
alias zless=$PAGER


#
# Language
#

# fixes strange cursor position / formating bug
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

#
# Paths
#

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

# Set the list of directories that Zsh searches for programs.
path=(
  ${HOME}/.pyenv/bin
  ${HOME}/.linuxbrew/bin
  ${HOME}/.cabal/bin
  ${HOME}/.local/{usr/,}{bin,sbin}
  ${HOME}/bin
  /usr/local/{bin,sbin}
  /usr/{bin,sbin}
  /{bin,sbin}
  $path
)

# add only once!
local add_ld="$HOME/.local/lib:$HOME/.local/usr/lib"
if test "${LD_LIBRARY_PATH#*$add_ld}" != "$LD_LIBRARY_PATH"
then
else
   export LD_LIBRARY_PATH=$add_ld:$LD_LIBRARY_PATH
fi

# 
# Python PyEnv
#

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

#
# Less
#

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-g -i -M -R -S -w -r -z-4'

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
   export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
#else
  # export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
fi

#
# Temporary Files
#

if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$USER"
  mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"
if [[ ! -d "$TMPPREFIX" ]]; then
  mkdir -p "$TMPPREFIX"
fi

# make anacron work for user set up
# if [ -d ${HOME}/.anacron/etc ]; then
   # /usr/sbin/anacron -s -t ${HOME}/.anacron/etc/anacrontab -S ${HOME}/.anacron/spool
# fi

# export TERM=xterm-256color        # for common 256 color terminals (e.g. gnome-terminal)
# get some more sophisticated dir colors :D
eval `dircolors ~/.config/dircolors.256dark`

# source frq specifics if present
[[ -f ~/.zprofile.frq ]] && source ~/.zprofile.frq
