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
        puppet module install "${mod}"
      else
        puppet module install "${mod%@*}" --version "${mod#*@}"
      fi
    else
      if file="$(getfile "${mod}")"; then
        json=$(tar -xf "${file}" --to-stdout "$(tar -tf "${file}" | grep -E '[^/]*/metadata.json')")
        arr=($(echo "${json}" | python -c 'import json,sys; obj=json.load(sys.stdin); print obj["name"]+"\n"+obj["version"];'))
        newfile="${file%%/*}/${arr[0]}-${arr[1]}.tar.gz"
        ln "${file}" "${newfile}"
        puppet module install "${newfile}" --ignore-dependencies
      else
        echo "Failed to download ${mod}" >&2
        return 2
      fi
    fi
  done
}

export -f installPuppetModules
