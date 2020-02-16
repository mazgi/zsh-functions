# depends on:
#   - hub
function create-repository() {
  # ToDo:
  if (( ! $+commands[hub] )); then
    echo 'command `hub` not exist!'
    return -9
  fi

  local -A opts
  local usage_msgs
  local err_msg
  local show_help_and_return_err=false
  local hub_cmd
  local git_service_base_url="github.com"
  local is_private=true
  local description
  local namespace_with_name

  # build message for usage
  usage_msgs=(
  "usage: $0"
  "        [-h | --help]"
  "        [-S <github.com|other> | --service <github.com|other>]"
  "        [--public]"
  "        [-D <description> | --description <description>]"
  "        <namespace/repository>"
  ""
  "hints:"
  "       - You can delete a repository via \`hub delete\` command."
  ""
  "references:"
  "       - https://hub.github.com/hub-create.1.html"
  "       - https://hub.github.com/hub-delete.1.html"
  )

  # parse arguments
  zparseopts -D -M -A opts -E -- h -help=h S: -service:=S -public D: -description:=D
  if [[ -n ${opts[(i)-h]} ]]; then
    printf "%s\n" "${usage_msgs[@]}"
    return;
  fi
  if [[ -n ${opts[(i)-S]} ]]; then
    git_service_base_url=${opts[-S]}
  fi
  if [[ -n ${opts[(i)--public]} ]]; then
    is_private=false
  fi
  if [[ -n ${opts[(i)-D]} ]]; then
    description=${opts[-D]}
  fi
  if [[ $# -eq 1 ]]; then
    namespace_with_name=$1
    shift
  else
    err_msg="Invalid arguments length!"
    show_help_and_return_err=true
  fi

  # build hub command line
  hub_cmd+="hub create "
  test $is_private = true && hub_cmd+="-p "
  test -n "$description" && hub_cmd+="-d \"${description}\" "
  hub_cmd+=$namespace_with_name

  # create the repository with built command
  repository_path="$(ghq root)/$git_service_base_url/$namespace_with_name"
  if [[ ! -e "$repository_path" ]]; then
    mkdir -p "$repository_path"
    printf "Execute command \`%s\` on '%s' ...\n" "$hub_cmd" "$repository_path"
    (
    cd "$repository_path"
    git init
    eval "$hub_cmd"
    )
  else
    err_msg=$(printf "The repository path '%s' already exists on \`ghq root\`!" $namespace_with_name)
    show_help_and_return_err=true
  fi

  if [[ $show_help_and_return_err = true ]]; then
    >&2 (
    tput setaf 1 && \
      printf "Error: %s\n" "$err_msg" && \
      tput sgr0 && \
      echo;
    )
    printf "%s\n" "${usage_msgs[@]}"
    return -1
  fi
}
