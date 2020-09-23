#!/usr/bin/env bats
load 'test_helper.sh'

function setup {
  export KEYCHAIN_PASSWORD='test-password'

  custom_keychain_name='CustomFileVaultMaster'
  custom_destination_dir="$(mktemp -d)"
  custom_keychain_file="${custom_keychain_name}.keychain"
  custom_der_cert="${custom_keychain_name}.der.cer"
  custom_keychain_password_file="${custom_keychain_name}-keychain-password.txt"

  default_keychain_name='FileVaultMaster'
  default_destination_dir='filevault-recovery-key'
  default_keychain_file="${default_keychain_name}.keychain"
  default_der_cert="${default_keychain_name}.der.cer"
  default_keychain_password_file="${default_keychain_name}-keychain-password.txt"
}

function teardown {
  if [[ -d $custom_destination_dir ]]; then rm -rf "$custom_destination_dir"; fi
  if [[ -d $default_destination_dir ]]; then rm -rf "$default_destination_dir"; fi
}

@test './filevault-recovery-key-generator.sh is executable' {
  assert_file_executable './filevault-recovery-key-generator.sh'
}

@test './filevault-recovery-key-generator.sh (no arguments)' {
  run ./filevault-recovery-key-generator.sh
  assert_dir_exist  "$default_destination_dir"
  assert_file_exist "${default_destination_dir}/${default_keychain_file}"
  assert_file_exist "${default_destination_dir}/${default_der_cert}"
  assert_file_exist "${default_destination_dir}/${default_keychain_password_file}"
}

@test './filevault-recovery-key-generator.sh <invalid-argument>' {
  run ./filevault-recovery-key-generator.sh 'invalid-argument'
  assert_output --partial 'Error'
}

@test './filevault-recovery-key-generator.sh -h' {
  run ./filevault-recovery-key-generator.sh -h
  assert_output --partial 'Usage:'
}

@test './filevault-recovery-key-generator.sh -d custom/dest/dir' {
  run ./filevault-recovery-key-generator.sh -d "$custom_destination_dir"
  assert_dir_exist  "$custom_destination_dir"
  assert_file_exist "${custom_destination_dir}/${default_keychain_file}"
  assert_file_exist "${custom_destination_dir}/${default_der_cert}"
  assert_file_exist "${custom_destination_dir}/${default_keychain_password_file}"
}

@test './filevault-recovery-key-generator.sh -d <missing-argument>' {
  run ./filevault-recovery-key-generator.sh -d
  assert_output --partial 'Error'
}

@test './filevault-recovery-key-generator.sh -n CustomCertName' {
  run ./filevault-recovery-key-generator.sh -n "$custom_keychain_name"
  assert_dir_exist  "$default_destination_dir"
  assert_file_exist "${default_destination_dir}/${custom_keychain_file}"
  assert_file_exist "${default_destination_dir}/${custom_der_cert}"
  assert_file_exist "${default_destination_dir}/${custom_keychain_password_file}"
}

@test './filevault-recovery-key-generator.sh -n <missing-argument>' {
  run ./filevault-recovery-key-generator.sh -n
  assert_output --partial 'Error'
}

@test './filevault-recovery-key-generator.sh -invalid-option' {
  run ./filevault-recovery-key-generator.sh -invalid-option
  assert_output --partial 'Error'
}

@test 'Run twice: keychain file already exists' {
  run ./filevault-recovery-key-generator.sh
  run ./filevault-recovery-key-generator.sh
  assert_output --partial 'already exists'
}
