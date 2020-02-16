function switch-branch() {
  if [[ $(git status 2> /dev/null) ]]; then
    target=$(git branch -vv | fzf-tmux | tr -d '*' | awk '{print $1}')
    test ! -z ${target} && git checkout ${target}
  fi
}
