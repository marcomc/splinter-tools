#!/usr/bin/env bash
#
# TODO
# - Allow parameters to chose the Mackup storage engine/directory
#
#

function show_usage {
printf  "usage: %s [option] action\n" "$0"
cat << 'EOF'

options:
       -d|--directory directory   Destination directory to store the lists
       -r|--repo      repo_url    repo url for Macpref installation
       -m|--macprefs  directory   path for Macpref installation directory
       --help                     Print help

action:
       backup                     Export system config file with Macprefs
       restore                    Restore system config file with Macprefs
EOF
  return 0
}

function setup_environment {
  [[ -z $macprefs_repo ]] && macprefs_repo='https://github.com/marcomc/macprefs'
  [[ -z $macprefs_dir ]] && macprefs_dir='./macprefs'
  [[ -z $backup_dir ]] && backup_dir='./system_preferences' # default destination if no '-d' is specified
  macprefs_tool="${macprefs_dir}/macprefs"
}

function install_macprefs {
  local temp_dir
  temp_dir=$(mktemp -d)
  macprefs_archive='macprefs.zip'
  macprefs_archive_url="$macprefs_repo/archive/master.zip"

  printf ">>>>>>>>>> Installing a local copy of Macprefs\n"

  printf ">>>>>>>>>> Downloading Macprefs into '%s/%s'\n" "$temp_dir" "$macprefs_archive"
  curl -H 'Cache-Control: no-cache' -fsSL "$macprefs_archive_url" -o "${temp_dir}/${macprefs_archive}" || exit 1

  printf ">>>>>>>>>> Decompressing Macprefs archive into '%s'\n" "$temp_dir"
  unzip -qq "${temp_dir}/${macprefs_archive}" -d "${temp_dir}" || exit 1

  printf ">>>>>>>>>> Installing Macprefs files to '%s'\n" "$macprefs_dir"
  [[ ! -d $macprefs_dir ]] && mkdir -p "$macprefs_dir"

  rsync --exclude .git --exclude .gitmodules --exclude .gitignore --exclude .travis.yml --exclude tests/ -rlWuv "$temp_dir"/*/* "$macprefs_dir" || exit

  printf ">>>>>>>>>> Removing temporary files\n"
  rm -rf "$temp_dir" || exit

  printf ">>>>>>>>>> Installation successful!\n"

}

function run_macprefs {
  local action="$1"
  local macprefs_log="${macprefs_dir}/macprefs.log"
  if [[ $action == 'restore' ]] && [[ ! -d $backup_dir ]]; then
      printf ">>>>>>>>>> Error: Backup dir '%s' is not available" "${backup_dir}"
      exit 1
  fi
  if [[ -x $macprefs_tool ]]; then
    #  Any preferences Mackup backs up won't be backed up by Macprefs
    printf ">>>>>>>>>> Running macprefs $action using '%s'..." "${backup_dir}"
    MACPREFS_BACKUP_DIR="$backup_dir" eval "$macprefs_tool" -v "$action" > "$macprefs_log" 2>&1
    printf "   done!\n"
  else
    printf ">>>>>>>>>> Error: %s is not available or executable" "${macprefs_tool}"
    exit 1
  fi
}

function main {
  case "$1" in
    -d|--directory)
      backup_dir="$2"
      shift 2
      ;;
    -r|--repo)
      macprefs_repo="$2"
      shift 2
      ;;
    -m|--macprefs)
      macprefs_dir="$2"
      shift 2
      ;;
    --help)
      eval show_usage
      exit 0
      ;;
    -*)
      echo ">>>>>>>>>> Error: Invalid option: $1." 1>&2
      exit 1
      ;;
  esac

  action="$1";
  case "$action" in
    backup)
      action_requested="backup"
      ;;
    restore)
      action_requested="restore"
      ;;
    '')
      echo ">>>>>>>>>> Error: Missing action" 1>&2
      eval show_usage
      exit 1
      ;;
    *)
      echo ">>>>>>>>>> Error: Invalid action '$action'" 1>&2
      exit 1
      ;;
  esac

  eval setup_environment
  [[ ! -x $macprefs_tool ]] && eval install_macprefs
  [[ -n $action_requested ]] && eval run_macprefs "$action_requested"
  exit 0
}

main "$@"
