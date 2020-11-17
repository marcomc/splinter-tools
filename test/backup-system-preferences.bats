#!/usr/bin/env bats
load 'test_helper.sh'

function setup {
  TEST_TEMP_DIR="$(mktemp -d)"
  macprefs_archive='macprefs.zip'

  custom_macprefs_repo='https://github.com/clintmod/macprefs'
  custom_macprefs_dir="${TEST_TEMP_DIR}/macprefs"
  custom_backup_dir="${TEST_TEMP_DIR}/custom_backup_directory"

  default_macprefs_dir='./macprefs'
  default_backup_dir='./system_preferences'

  incorrect_macprefs_repo='https://github.com/clintmod/macprefs/tree/test'
}

function teardown {
  rm -rf "$TEST_TEMP_DIR"
  if [[ -f $macprefs_archive ]]; then rm "$macprefs_archive"; fi
  if [[ -d $default_macprefs_dir ]]; then rm -rf "$default_macprefs_dir"; fi
  if [[ -d $default_backup_dir ]]; then rm -rf "$default_backup_dir"; fi
}


@test './backup-system-preferences.sh is executable' {
  assert_file_executable './backup-system-preferences.sh'
}

@test './backup-system-preferences.sh -h - expected to print usage messages' {
  run ./backup-system-preferences.sh -h
  assert_output --partial 'usage:'
}

@test './backup-system-preferences.sh (no argument) - expected to fail' {
  run ./backup-system-preferences.sh
  assert_output --partial 'Error: Missing action'
  assert_failure
}

@test './backup-system-preferences.sh -z <invalid-option> - expected to fail' {
  run ./backup-system-preferences.sh -z
  assert_output --partial 'Error: Invalid option'
  assert_failure
}

@test './backup-system-preferences.sh <invalid-action> - expected to fail' {
  run ./backup-system-preferences.sh 'invalid-action'
  assert_output --partial 'Error: Invalid action'
  assert_failure
}

@test "./backup-system-preferences.sh install - expected to create './macprefs'" {
  run ./backup-system-preferences.sh install
  assert_output --partial 'Installing a local copy of Macprefs'
  assert_dir_exist "$default_macprefs_dir"
  assert_success
}

@test "./backup-system-preferences.sh -m custom_macprefs_dir install - expected to create 'custom_macprefs_dir'" {
  run ./backup-system-preferences.sh -m "$custom_macprefs_dir" install
  assert_output --partial 'Installing a local copy of Macprefs'
  assert_dir_exist "$custom_macprefs_dir"
  assert_success
}

@test "./backup-system-preferences.sh install (when macprefs is already installed) - expected NOT to fail but not proceed with the installation" {
  run ./backup-system-preferences.sh install
  run ./backup-system-preferences.sh install
  assert_output --partial 'Macprefs is already installed'
  assert_dir_exist "$default_macprefs_dir"
  assert_success
}

@test "./backup-system-preferences.sh backup - expected to create './system_preferences'" {
  run ./backup-system-preferences.sh backup
    assert_output --partial 'Running macprefs backup'
  assert_dir_exist "$default_backup_dir"
  assert_success
}

@test './backup-system-preferences.sh restore - expected to complete successfully' {
  run ./backup-system-preferences.sh backup
  run ./backup-system-preferences.sh restore
  assert_output --partial 'Running macprefs restore'
  assert_success
}

@test './backup-system-preferences.sh restore (without a previous backup) - expected to fail' {
  run ./backup-system-preferences.sh restore
  assert_output --partial 'Error: Backup dir'
  assert_output --partial 'is not available'
  assert_failure
}

@test './backup-system-preferences.sh -d custom_backup_dir restore - expected to complete successfully' {
  run ./backup-system-preferences.sh -d "$custom_backup_dir" backup
  run ./backup-system-preferences.sh -d "$custom_backup_dir" restore
  assert_output --partial 'Running macprefs restore'
  assert_success
}

@test './backup-system-preferences.sh -m custom_macprefs_dir restore - expected to complete successfully' {
  run ./backup-system-preferences.sh -m "$custom_macprefs_dir" backup
  run ./backup-system-preferences.sh -m "$custom_macprefs_dir" restore
  assert_output --partial 'Running macprefs restore'
  assert_success
}

@test './backup-system-preferences.sh -r custom_macprefs_repo restore - expected to complete successfully' {
  run ./backup-system-preferences.sh -r "$custom_macprefs_repo" backup
  run ./backup-system-preferences.sh -r "$custom_macprefs_repo" restore
  assert_output --partial 'Running macprefs restore'
  assert_success
}

@test './backup-system-preferences.sh -r incorrect_macprefs_repo restore - expected to fail' {
  run ./backup-system-preferences.sh -r "$incorrect_macprefs_repo" backup
  assert_output --partial 'Downloading'
  assert_failure
}

@test './backup-system-preferences.sh -d custom_backup_dir -m custom_macprefs_dir -r custom_macprefs_repo restore - expected to complete successfully' {
  run ./backup-system-preferences.sh -d "$custom_backup_dir" -m "$custom_macprefs_dir" -r "$custom_macprefs_repo" backup
  run ./backup-system-preferences.sh -d "$custom_backup_dir" -m "$custom_macprefs_dir" -r "$custom_macprefs_repo" restore
  assert_output --partial 'Running macprefs restore'
  assert_success
}
