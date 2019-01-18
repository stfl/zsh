# export _ZPLUG_PREZTO="zsh-users/prezto"

zplug "zplug/zplug", hook-build:"zplug --self-manage"

# prezto options
zstyle ':prezto:module:*' color 'yes'
zstyle ':prezto:module:*' case-sensitive 'no'
zstyle ':prezto:module:prompt' theme sorin
zstyle ':prezto:module:editor' key-bindings 'vi'
zstyle ':prezto:module:editor' dot-expansion 'yes'

zstyle ':prezto:module:syntax-highlighting' styles \
  'alias'             'fg=blue' \
  'builtin'           'fg=blue' \
  'command'           'fg=blue' \
  'function'          'fg=blue' \
  'precommand'        'fg=cyan' \
  'commandseparator'  'fg=green'

# zstyle ':prezto:module:history-substring-search:color' found 'bg=magenta'
# zstyle ':prezto:module:history-substring-search:color' not-found ''

zstyle ':prezto:module:ssh:load' identities \
  'google_compute_engine' \
  'id_ecdsa' \
  'id_rsa' \
  'id_rsa_bb' \
  'id_rsa_boards' \
  'id_rsa_me_bb'

zstyle ':prezto:module:utility:make' color 'yes'
zstyle ':prezto:module:utility:diff' color 'yes'
zstyle ':prezto:module:utility:ls' color 'yes'

zplug "sorin-ionescu/prezto", use:"init.zsh", \
  hook-build:"ln -s $ZPLUG_HOME/repos/sorin-ionescu/prezto ~/.zprezto"

zplug "modules/environment", from:prezto, defer:0

# Syntax highlighting for commands, load last
# zplug "zsh-users/zsh-syntax-highlighting", from:github
# zplug "zsh-users/zsh-history-substring-search", from:github
zplug "modules/history", from:prezto
zplug "modules/git", from:prezto
zplug "modules/ssh", from:prezto

zplug "modules/directory", from:prezto
zplug "modules/editor", from:prezto
zplug "modules/spectrum", from:prezto

zplug "modules/prompt", from:prezto
zplug "modules/utility", from:prezto
zplug "modules/command-not-found", from:prezto, lazy:yes
zplug "modules/completion", from:prezto, defer:1, lazy:yes

zplug "modules/syntax-highlighting", from:prezto, defer:2, lazy:yes
zplug "modules/history-substring-search", from:prezto, defer:3, lazy:yes

# Load completion library for those sweet [tab] squares
# zplug "lib/completion", from:oh-my-zsh
zplug "zsh-users/zsh-completions"

zplug "djui/alias-tips", lazy:yes
zplug "b4b4r07/enhancd", use:enhancd.sh
zplug "b4b4r07/zplug-doctor", lazy:yes
zplug "b4b4r07/zplug-cd", lazy:yes
zplug "b4b4r07/zplug-rm", lazy:yes

zplug "changyuheng/zsh-interactive-cd", defer:3, use:zsh-interactive-cd.plugin.zsh

# Theme!
# Async for zsh, used by pure
# zplug "mafredri/zsh-async", from:github, defer:0
# zplug "sindresorhus/pure", use:pure.zsh, as:theme

# z instead of fasd
# zplug "knu/z", use:z.sh, defer:3, lazy:yes

# completions
zplug "felixr/docker-zsh-completion", lazy:yes
zplug "plugins/cargo", from:oh-my-zsh, lazy:yes
zplug "rust-lang/zsh-config", use:_rust, lazy:yes

# this is installed in the system with docker-compose
# zplug "docker/compose", use:_docker-compose

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load
