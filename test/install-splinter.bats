#!/usr/bin/env bats
load 'test_helper.sh'

function setup {
  splinter_dir='./splinter'
  splinter_script="$splinter_dir/splinter"
  splinter_tools_dir="$splinter_dir/tools"
  splinter_test_dir="$splinter_dir/test"
  splinter_travis_config="$splinter_dir/.travis.yml"
  splinter_gitignore="$splinter_dir/.gitignore"
  splinter_gitmodules="$splinter_dir/.gitmodules"
  export_apps_lists_script="$splinter_tools_dir/export-apps-lists.sh"
  backup_system_preferences_script="$splinter_tools_dir/backup-system-preferences.sh"
  filevault_recovery_key_generator_script="$splinter_tools_dir/filevault-recovery-key-generator.sh"
  install_splinter_script="$splinter_tools_dir/install-splinter"
}

function teardown {
  if [[ -d $splinter_dir ]]; then rm -rf "$splinter_dir"; fi
}

@test './splinter-install is executable' {
  assert_file_executable './install-splinter'
}

@test './splinter-install (successful splinter installation)' {
  run ./install-splinter
  assert_dir_exist       "$splinter_dir"
  assert_dir_exist       "$splinter_tools_dir"
  assert_dir_not_exist   "$splinter_test_dir"
  assert_file_not_exist  "$splinter_travis_config"
  assert_file_not_exist  "$splinter_gitignore"
  assert_file_not_exist  "$splinter_gitmodules"
  assert_file_executable "$splinter_script"
  assert_file_executable "$export_apps_lists_script"
  assert_file_executable "$filevault_recovery_key_generator_script"
  assert_file_executable "$install_splinter_script"
  assert_file_executable "$backup_system_preferences_script"
}
