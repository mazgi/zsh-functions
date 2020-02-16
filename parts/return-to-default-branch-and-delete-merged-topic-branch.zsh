function return-to-default-branch-and-delete-merged-topic-branch() {
  if [[ $(git status 2> /dev/null) ]]; then
    # Get default and topic branch.
    local default_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
    local topic_branch=$(git rev-parse --abbrev-ref HEAD)
    if [[ -z $default_branch ]] || [[ -z $topic_branch ]]; then
      tput setaf 1 && \
        printf "Cannot get default or topic branch!\n"
      return -1
    fi

    # Do nothing if the current branch is the same as the default branch.
    if [[ $default_branch = $topic_branch ]]; then
      printf "Already on default branch '%s'.\n" $default_branch
      return
    fi

    # Switch back to the default branch && delete the merged topic branch.
    printf "Topic branch '%s' will be removed.\n" $topic_branch
    tput bold && \
      tput setaf 3 && \
      printf "Are you sure? [y/N]: " && \
      tput sgr0
    if read -q; then
      echo;
      git checkout $default_branch && \
        git fetch origin --prune && \
        git merge --ff-only origin/$default_branch && \
        git branch -d $topic_branch
    fi
  fi
}
