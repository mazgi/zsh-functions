function create-new-tmux-session-for-working-directory() {
  tmux new -s ${$(basename $PWD)//\./+}
}
