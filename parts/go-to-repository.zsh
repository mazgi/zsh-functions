# depends on:
#   - ghq
#   - fzf
#   - tmux
#   - fzf-tmux
#   - (optional)vscode
function go-to-repository() {
  local -A opts
  local usage_msgs
  local with_new_tmux_session=false

  # build message for usage
  usage_msgs=(
  "usage: $0"
  "        [-h | --help]"
  "        [-T | --with-tmux]"
  "        [-C | --with-code]"
  )

  # parse arguments
  zparseopts -D -M -A opts -E -- h -help=h T -with-tmux=T C -with-code=C
  if [[ -n ${opts[(i)-h]} ]]; then
    printf "%s\n" "${usage_msgs[@]}"
    return;
  fi
  if [[ -n ${opts[(i)-T]} ]]; then
    with_new_tmux_session=true
  fi
  if [[ -n ${opts[(i)-C]} ]]; then
    if (( $+commands[code] )); then
      with_new_vscode_window=true
    else
      tput setaf 3 && \
        printf "\"code\" command not found." && \
        tput sgr0
    fi
  fi

  # to repository
  to=$(ghq root)/$(ghq list | fzf-tmux)
  if [[ -n "$to" ]]; then
    cd "$to"

    # (optionnal)create new tmux session
    if [[ $with_new_tmux_session = true ]] && [[ -z $TMUX ]]; then
      name="$(basename $(cd ../..; pwd))" # e.g. "github.com"
      name+="/$(basename $(cd ..; pwd))"  # e.g. "github.com/mazgi"
      name+="/$(basename $PWD)"           # e.g. "github.com/mazgi/.dotfiles"
      tmux new -s "${name//\./+}"         # e.g. "github+com/mazgi/+dotfiles"
    fi

    # (optionnal)open via vscode
    if [[ $with_new_vscode_window = true ]] ; then
      code .
    fi
  fi
}
