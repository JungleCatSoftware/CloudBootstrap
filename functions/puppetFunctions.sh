function installLibrarianPuppetModules {
  if [ $# -lt 1 ]; then
    echo "No Puppetfile given" >&2
    return 1
  fi

  # Install librarian-puppet dependencies
  DEBIAN_FRONTEND=noninteractive apt-get --assume-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install build-essential ruby-dev
  # Install librarian-puppet
  gem install librarian-puppet

  success=0

  if file="$(getfile "${1}")"; then
    PuppetDir="/etc/puppet"
    ln "${file}" "${PuppetDir}/Puppetfile"
    (
      cd "${PuppetDir}"
      if ! librarian-puppet install; then
        echo "Error running puppet-librarian" >&2
        exit 2
      fi
    )
    success=$?
  else
    echo "Failed to download ${1}" >&2
    success=3
  fi

  DEBIAN_FRONTEND=noninteractive apt-get --assume-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" purge build-essential ruby-dev
  gem uninstall librarian-puppet
  return $success
}

function installPuppetModules {
  if [ $# -lt 1 ]; then
    echo "No Puppet modules defined" >&2
    return 1
  fi

  for mod in "$@"; do
    echo "Installing Puppet module: ${mod}"
    if [[ "${mod}" =~ ^forge: ]]; then
      mod="${mod#forge:}"
      if [[ "${mod}" == "${mod%@*}" ]]; then
        puppet module install --force "${mod}"
      else
        puppet module install --force "${mod%@*}" --version "${mod#*@}"
      fi
    else
      if file="$(getfile "${mod}")"; then
        json=$(tar -xf "${file}" --to-stdout "$(tar -tf "${file}" | grep -E '[^/]*/metadata.json')")
        arr=($(echo "${json}" | python -c 'import json,sys; obj=json.load(sys.stdin); print obj["name"]+"\n"+obj["version"];'))
        newfile="${file%%/*}/${arr[0]}-${arr[1]}.tar.gz"
        ln "${file}" "${newfile}"
        puppet module install --force "${newfile}" --ignore-dependencies
      else
        echo "Failed to download ${mod}" >&2
        return 2
      fi
    fi
  done
}

export -f installLibrarianPuppetModules installPuppetModules
