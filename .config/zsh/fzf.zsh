#  vim: set ft=zsh

# source fzf key bindings:
if [ -f /usr/share/fzf/shell/key-bindings.zsh ]; then
  # on Fedora:
  source /usr/share/fzf/shell/key-bindings.zsh
else
  # TODO
fi

# init fasd even if fzf does not exist
command -v fasd &>/dev/null && eval "$(fasd --init auto)"

# fzf functions
# https://github.com/junegunn/fzf/wiki/examples

# do not define fzf related functions if fzf does not exist
if ! command -v fzf &>/dev/null; then
  return 0
fi

export FZF_DEFAULT_OPTS="--reverse --inline-info --ansi
  --bind=ctrl-s:toggle-sort
  --bind=ctrl-u:half-page-up
  --bind=ctrl-d:half-page-down
"


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


# fbr - checkout git branch (including remote branches), sorted by most recent commit, limit 30 last branches
fbr() {
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# fco - checkout git branch/tag, with a preview showing the commits between the tag/branch and HEAD
fco() {
  local tags branches target
  tags=$(
git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
  branches=$(
git branch --all | grep -v HEAD |
sed "s/.* //" | sed "s#remotes/[^/]*/##" |
sort -u | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
  target=$(
(echo "$tags"; echo "$branches") |
    fzf --no-hscroll --no-multi --delimiter="\t" -n 2 \
        --ansi --preview="git log -200 --pretty=format:%s $(echo {+2..} |  sed 's/$/../' )" ) || return
  git checkout $(echo "$target" | awk '{print $2}')
}

alias glNoGraph='git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" "$@"'
alias glGraph='git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" "$@"'
_gitLogLineToHash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
_viewGitLogLine="$_gitLogLineToHash | xargs -I % sh -c 'git show --color=always % | diff-so-fancy'"

# fcoc_preview - checkout git commit with previews
fcoc() {
  local commit
  commit=$( glNoGraph |
    fzf --no-sort --reverse --tiebreak=index --no-multi \
        --ansi --preview="$_viewGitLogLine" ) &&
  git checkout $(echo "$commit" | sed "s/ .*//")
}

# fshow_preview - git commit browser with previews
fshow() {
    glGraph |
        fzf --no-sort --reverse --tiebreak=index --no-multi \
            --ansi --preview="$_viewGitLogLine" \
                --header "[enter]: view | <a-y> copy hash | <c-s> toggle sort ", \
                --bind "enter:execute:$_viewGitLogLine   | less -R" \
                --bind "alt-p:execute:$_gitLogLineToHash | xclip"
}

fcherry() {
    commits=$( glNoGraph |
        fzf --multi --reverse --tiebreak=index \
            --ansi --preview="$_viewGitLogLine") &&
      echo -n "cherry-picking: \n${commits}\n\n" &&
      for commit in $(echo "$commits" | sed "s/ .*//" | tac ); do
        git cherry-pick $commit
      done
}
