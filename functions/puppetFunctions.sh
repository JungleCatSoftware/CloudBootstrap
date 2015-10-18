function installLibrarianPuppetModules {
  if [ $# -lt 1 ]; then
    echo "No Puppetfile given" >&2
    return 1
  fi

  dependencies=(build-essential ruby-dev git)

  # Install librarian-puppet dependencies
  DEBIAN_FRONTEND=noninteractive apt-get --assume-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install "${dependencies[@]}"
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

  DEBIAN_FRONTEND=noninteractive apt-get --assume-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" purge "${dependencies[@]}"
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

function getHieraFile {
  if [ $# -lt 1 ]; then
    echo "No Hiera File defined" >&2
    return 1
  fi

  if file="$(getfile "${1}")"; then
    ln "${file}" "/etc/hiera.yaml"
    ln "${file}" "/etc/puppet/hiera.yaml"
  fi
}

function getHieraDataFiles {
  if [ $# -lt 1 ]; then
    echo "No Hiera Data Files defined" >&2
    return 1
  fi

  for datafile in "$@"; do
    echo "Installing data file: ${datafile}"

    IFS='|' filearray=(${datafile})

    if [ ${#filearray[@]} -eq 2 ] | [[ "${filearray[1]}" =~ ^/.+$ ]]; then
      echo "  Downloading \"${filearray[0]}\" to \"${filearray[1]}\""
      if file="$(getfile "${filearray[0]}")"; then
        filedir="$(dirname "${filearray[1]}")"
        if ! [ -d "${filedir}" ]; then
          mkdir -p "${filedir}"
        fi
        ln "${file}" "${filearray[1]}"
      else
        echo "Failed to download datafile: ${datafile}" >&2
        return 3
      fi
    else
      echo "Incorrect format for datafile: ${datafile}" >&2
      echo "  Please use format \"LOCATOR|ABS_LOCAL_PATH\"" >&2
      return 2
    fi
  done
}

export -f installLibrarianPuppetModules installPuppetModules getHieraFile getHieraDataFiles
