#
# Executes commands at login pre-zshrc.
#

# Browser
#

############ Editors{{{

if command -v nvim &>/dev/null; then
   export EDITOR='nvim'
   export VISUAL='nvim'
   # export MANPAGER="nvim -c 'set ft=man' -"
else
   export EDITOR='vim'
   export VISUAL='vim'
fi
# export PAGER='less' # 'vimpager'
# alias less=$PAGER
# alias zless=$PAGER

# }}}
############ Language{{{

# fixes strange cursor position / formating bug
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# }}}
############ Paths{{{

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

# Set the list of directories that Zsh searches for programs.
path=(
  # Haskell pkg manager Cabal
  ${HOME}/.cabal/bin
  
  # Yarn install
  ${HOME}/.yarn/bin

  # PHP Composer pkg manager
  ${HOME}/.config/composer/vendor/bin
  ${HOME}/.composer/vendor/bin

  # doom-emacs
  ${HOME}/.emacs.d/bin

  # self-compiled stuff
  ${HOME}/.local/{usr/,}{local/,}{bin,sbin}
  ${HOME}/bin

  # Anaconda on Arch
  ${HOME}/.anaconda3/bin
  ${HOME}/anaconda3/bin
  /opt/anaconda/bin

  # Python virtualenv
  ${HOME}/.pyenv/bin

  # binaries installed through Linuxbrew
  ${HOME}/.linuxbrew/bin

  # flatpak
  /var/lib/flatpak/exports/bin/

  # God knows why that's not always included..
  /{usr/,}{local/,}{bin,sbin}

  # perl binaries on arch...
  /usr/bin/core_perl/
  # /usr/bin/*_perl/

  # temporary for OmNET++
  # ${HOME}/Projects/omnetpp/omnetpp-5.1/bin

  # CUDA on Arch Linux > done by package manager
  # /opt/cuda/bin

  $path
)

add_ld=(
  "$HOME/.local/lib"
  "$HOME/.local/usr/lib"
  "/opt/cuda/lib"
  )

for (( i = 1; i <= ${#add_ld[*]}; i++ )) do
  add=${add_ld[i]}
  if test "${LD_LIBRARY_PATH} ==  ''"; then
    # add first one without :
    export LD_LIBRARY_PATH=$add
  elif ! test "${LD_LIBRARY_PATH#*$add}" != "$LD_LIBRARY_PATH"; then
    # add only once!
    export LD_LIBRARY_PATH=$add:$LD_LIBRARY_PATH
  fi
done

#  fpath

fpath=(
   ~/.config/zsh/completion/
   $fpath
)

# }}}
############ Python PyEnv {{{

# if command -v pyenv &>/dev/null; then
   # eval "$(pyenv init -)"
   # eval "$(pyenv virtualenv-init -)"
# fi

# }}}
############ shell options {{{

setopt RM_STAR_WAIT

# do not exit on Ctrl-D (10x EOF still works)
setopt IGNORE_EOF


# }}}
############ Less{{{

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

#}}}
############ Temporary Files{{{
#

if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$USER"
  mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"
if [[ ! -d "$TMPPREFIX" ]]; then
  mkdir -p "$TMPPREFIX"
fi
# }}}

# make anacron work for user set up
# if [ -d ${HOME}/.anacron/etc ]; then
   # /usr/sbin/anacron -s -t ${HOME}/.anacron/etc/anacrontab -S ${HOME}/.anacron/spool
# fi


# export TERM=xterm-256color        # for common 256 color terminals (e.g. gnome-terminal)
# get some more sophisticated dir colors :D
eval `dircolors ~/.config/dircolors.256dark`

# export SRCDIR="${HOME}/.cache/pacaur/"


export PATH="$HOME/.cargo/bin:$PATH"

export PATH="$HOME/.poetry/bin:$PATH"
export PATH="$HOME/.yarn/bin:$PATH"

export NODE_PATH=/usr/lib/nodejs:/usr/share/nodejs
