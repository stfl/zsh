# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/stefan/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  dotenv
  cargo
  rust
  rustup
  colored-man-pages
  command-not-found
  common-aliases
  colorize
  tmux
  ubuntu
  fasd
  fd
  fzf
  docker
  docker-compose
  emacs
  vi-mode
  sudo
  ssh-agent
  ripgrep
  python
  extract
  composer
  kubectl
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

alias rmv="rsync --remove-source-files --info=progress2 --partial -ha"
alias rcp="rsync --info=progress2 --partial -ha"

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

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
#         . "/opt/anaconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/opt/anaconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# <<< conda initialize <<<

# if [ -e /home/stefan/.nix-profile/etc/profile.d/nix.sh ]; then . /home/stefan/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
