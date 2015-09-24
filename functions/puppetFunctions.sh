function installPuppetModules {
  if [ $# -lt 1 ]; then
    echo "No Puppet modules defined" >&2
  fi

  for mod in "$@"; do
    echo "TODO: install ${mod}"
  done
}
