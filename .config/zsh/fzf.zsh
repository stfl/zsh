#  vim: set ft=zsh

# init fasd even if fzf does not exist
command -v fasd &>/dev/null && eval "$(fasd --init auto)"

# fzf functions
# https://github.com/junegunn/fzf/wiki/examples

# do not define fzf related functions if fzf does not exist
if ! command -v fzf &>/dev/null; then
  return 0
fi

export FZF_DEFAULT_OPTS="--reverse --inline-info --ansi"

if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git --color=always'

elif command -v ag &>/dev/null; then
   export FZF_DEFAULT_COMMAND='ag --hidden -g ""'
   # export FZF_DEFAULT_OPTS="--reverse --inline-info"

   _fzf_compgen_path() {
      ag -g "" "$1"
   }

fi

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_TMUX_HEIGHT="30%"

# use fasd 
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

# # fd - cd to selected directory
# fd() {
#    local dir
#    dir=$(find ${1:-.} -path '*/\.*' -prune \
#       -o -type d -print 2> /dev/null | fzf-tmux +m) \
#       && cd "$dir" \
#       || return 1
# }
# 
# # fda - including hidden directories
# fda() {
#    local dir
#    dir=$(find ${1:-.} -type d 2> /dev/null | fzf-tmux +m) \
#       && cd "$dir" \
#       || return 1
# }

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


### 

bindkey "^P" fzf-cd-widget

