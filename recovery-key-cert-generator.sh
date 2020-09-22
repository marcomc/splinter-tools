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
  red="\e[31m"
  green="\e[32m"
  yellow="\e[33m"
  cyan="\e[36m"
  white="\e[39m"

  [[ -z "$keychain_name" ]] && keychain_name='FileVaultMaster'
  [[ -z "$destination_dir" ]] && destination_dir="$(pwd)/recovery-key-cert"
  keychain_file="${destination_dir}/${keychain_name}.keychain"
  keychain_secret_output="${destination_dir}/${keychain_name}-keychain-password.txt"
  der_cert="${destination_dir}/${keychain_name}.der.cer"
}

function from_keychain_to_cert {

  printf "%b>>>>>>>>>>%b Creating %s keychain\n" "$green" "$white" "$keychain_file"
  security create-filevaultmaster-keychain -p "$KEYCHAIN_PASSWORD" "$keychain_file"
  printf "%b>>>>>>>>>>%b Exporting DER certificate %s from %s keychain\n" "$green" "$white" "$der_cert" "$keychain_file"
  security export -k "$keychain_file" -t certs -o "$der_cert"
}

function ask_for_private_key_secret {
  local keychain_password=""
  if [[ -z $KEYCHAIN_PASSWORD ]]; then
    printf "%b>>>>>>>>>>%b Requesting the secret used to encript %s\n" "$green" "$white" "$keychain_file"
    read -r -p ">>>>>>>>>> Insert your chosen secret: " -s keychain_password
    printf "\n"
    export KEYCHAIN_PASSWORD="$keychain_password"
    printf "%b>>>>>>>>>>%b Keychain password saved in %s\n" "$cyan" "$white" "$keychain_secret_output"
    echo "$KEYCHAIN_PASSWORD" > "$keychain_secret_output"
    chmod 0600 "$keychain_secret_output"
    printf "%b>>>>>>>>>> Store the keychain password in a safe place (i.e. Bitwarden, LastPass or 1Password)%b\n" "$yellow" "$white"
    printf "%b>>>>>>>>>> then delete the file %s%b\n" "$yellow" "$keychain_secret_output" "$white"
  else
    printf "%b>>>>>>>>>>%b 'KEYCHAIN_PASSWORD' is already set\n" "$yellow" "$white"
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
    printf "%b>>>>>>>>>>%b The keychain file '%s' already exists!\n" "$yellow" "$white" "$keychain_file"
    exit
  else
    eval ask_for_private_key_secret
    eval from_keychain_to_cert
    printf "%b>>>>>>>>>>%b Opening the keychain '%s' for review\n" "$green" "$white" "$keychain_name"
    open "$keychain_file"
  fi
  open "$destination_dir"
}

main "$@"
