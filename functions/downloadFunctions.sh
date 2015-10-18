function getfile {
  if [ $# == 1 ]; then
    file=$1
  else
    echo "Error: No file provided to download" >&2
    return 1
  fi

  if [[ ${file} =~ ^https?:// ]]; then
    url=${file}
  elif [[ ${file} =~ ^github: ]]; then
    if ! url=$(github_parse_path ${file}); then
      echo "Error parsing ConfigFile as GitHub URL: ${file}" >&2
      echo "  Function exited with code: $?" >&2
      return 2
    fi
  elif [[ ${file} =~ ^file: ]]; then
    url=${file}
  fi

  if [[ "x${url}" == "x" ]]; then
    echo "Error: URL is empty string" >&2
    return 3
  fi

  dir="/tmp/$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w "$((($RANDOM%20)+5))" | head -n1)"
  if ! mkdir -p "${dir}"; then
    echo "Could not create tmp directory ${dir}" >&2
    return 4
  fi
  filename=${dir}/${url##*/}

  if [[ ${url} =~ ^file: ]]; then
    if cp "${file#file:}" "${filename}"; then
      echo ${filename}
    else
      echo "Failed to copy file: ${file}" >&2
      return 5
    fi
  else
    if which curl >/dev/null; then
      if resp=$(curl --location --write-out %{http_code} --silent --output "${filename}" "${url}"); then
        if [[ $resp -eq 200 ]]; then
          echo ${filename}
        else
          echo "HTTP error on download: ${url} - ${resp}" >&2
          return 6
        fi
      else
        echo "Curl command failed" >&2
        return 5
      fi
    elif which wget >/dev/null; then
      if wget --quiet -output-document "${filename}" "${url}"; then
        echo ${filename}
      else
        echo "Wget command failed" >&2
        return 5
      fi
    fi
  fi
}

export -f getfile
