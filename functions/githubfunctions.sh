export githubraw="https://raw.githubusercontent.com/%user%/%repo%/%tag%/%filepath%"
export githubarchive="https://github.com/%user%/%repo%/archive/%tag%.tar.gz"

function github_parse_path {
  if [ $# == 1 ]; then
    loc=$1
  else
    return 1
  fi
  if ! [[ ${loc} =~ ^github: ]]; then
    return 2
  fi

  user=$([[ ${loc} =~ ^github:([[:alnum:]]*) ]] && echo ${BASH_REMATCH[1]} || return 3)
  repo=$([[ ${loc} =~ ^github:[[:alnum:]]*/([[:alnum:]]*) ]] && echo ${BASH_REMATCH[1]} || return 3)
  filepath=$([[ ${loc} =~ ^github:([[:alnum:]]*/){2}([^@]*)(@|$) ]] && echo ${BASH_REMATCH[2]})
  tag=$([[ ${loc} =~ @(.*)$ ]] && echo ${BASH_REMATCH[1]} || echo "master")

  if [[ "x${filepath}" == "x" ]]; then
    GitHubURL=$githubarchive
  else
    GitHubURL=$githubraw
  fi

  echo "${GitHubURL}" | sed 's/%user%/'"${user}"'/' | sed 's/%repo%/'"${repo}"'/' | sed 's/%tag%/'"${tag}"'/' | sed 's/%filepath%/'"${filepath/\//\\/}"'/'
}

export -f github_parse_path
