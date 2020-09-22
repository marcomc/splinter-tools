#!/bin/bash

function abs_path {
  local file="$1"
  local absolute_path=""
  directory=$(dirname "$file")
  # shellcheck disable=SC2001 # can't avoid the use of sed
  directory=$(echo "$directory" | sed 's+~+'"${HOME}"'+g' )
  absolute_path="$(cd "$directory"|| exit 1; pwd )"
  echo "${absolute_path}/$(basename "$file")"
}

function setup_environment {
  yellow="\e[33m"
  white="\e[39m"

  [[ -z "$keychain_name" ]] && keychain_name='FileVaultMaster'
  [[ -z "$destination_dir" ]] && destination_dir="$(pwd)/filevault-recovery-key"

  keychain_file="${destination_dir}/${keychain_name}.keychain"
  keychain_secret_output="${destination_dir}/${keychain_name}-keychain-password.txt"
  der_cert="${destination_dir}/${keychain_name}.der.cer"
}

function from_keychain_to_cert {
  printf ">>>>>>>>>> Creating %s keychain\n" "$keychain_file"
  security create-filevaultmaster-keychain -p "$KEYCHAIN_PASSWORD" "$keychain_file"
  printf ">>>>>>>>>> Extracting DER certificate %s from the keychain file\n" "$der_cert"
  security export -k "$keychain_file" -t certs -o "$der_cert"
}

function ask_for_private_key_secret {
  local keychain_password=""
  if [[ -z $KEYCHAIN_PASSWORD ]]; then
    printf ">>>>>>>>>> Requesting the secret used to encript %s\n" "$keychain_file"
    read -r -p ">>>>>>>>>> Choose a 'FileVault Master Password Key': " -s keychain_password
    printf "\n"
    export KEYCHAIN_PASSWORD="$keychain_password"
    printf ">>>>>>>>>> Keychain password saved in %s\n" "$keychain_secret_output"
    echo "$KEYCHAIN_PASSWORD" > "$keychain_secret_output"
    chmod 0600 "$keychain_secret_output"
    printf ">>>>>>>>>> %bStore the keychain password in a safe place (i.e. Bitwarden, LastPass or 1Password)%b\n" "$yellow" "$white"
    printf ">>>>>>>>>> %bthen delete the file %s%b\n" "$yellow" "$keychain_secret_output" "$white"
  else
    printf ">>>>>>>>>> 'KEYCHAIN_PASSWORD' is already set\n"
  fi
}

function main {
  while getopts ":d:n:h" option; do
    case "$option" in
      d)
        destination_dir="$(abs_path "$OPTARG")"
        ;;
      n)
        keychain_name="${OPTARG}"
        ;;
      h)
        printf "Usage: %s [ -d path/to/destination/dir ] [ -n KeychainName ]\n" "$0"
        exit 0
        ;;
      \?)
        echo ">>>>>>>>>> Error: Invalid Option '-$option'" 1>&2
        eval show_usage 1>&2
        exit 1
        ;;
      :)
        echo ">>>>>>>>>> Error: Option '-$option' is missing an argument" 1>&2
        eval show_usage 1>&2
        exit 1
        ;;
    esac
  done

  eval setup_environment

  [ ! -d "$destination_dir" ] &&  mkdir -p "$destination_dir"
  if [ -f "$keychain_file" ];then
    printf ">>>>>>>>>> The keychain file '%s' already exists!\n" "$keychain_file"
    exit
  else
    eval ask_for_private_key_secret
    eval from_keychain_to_cert
    printf ">>>>>>>>>> Opening the keychain '%s' for review\n" "$keychain_name"
    open "$keychain_file"
  fi
  open "$destination_dir"
}

main "$@"
