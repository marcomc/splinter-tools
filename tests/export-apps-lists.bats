#!/usr/bin/env bats
load 'test_helper.sh'

function setup {
  TEST_TEMP_DIR="$(mktemp -d)"
  homebrew_cask_apps_list='homebrew_cask_apps.txt'
  homebrew_packages_list='homebrew_packages.txt'
  homebrew_taps_list='homebrew_taps.txt'
  mas_apps_list='mas_apps.txt'
  npm_global_packages_list='npm_global_packages.json'
  pip_packages_list='pip_packages.txt'
  ruby_gems_list='ruby_gems.txt'
}

function teardown {
  rm -rf "$TEST_TEMP_DIR"
  if [[ -f $homebrew_cask_apps_list ]]; then rm "$homebrew_cask_apps_list"; fi
  if [[ -f $homebrew_packages_list ]]; then rm "$homebrew_packages_list"; fi
  if [[ -f $homebrew_taps_list ]]; then rm "$homebrew_taps_list"; fi
  if [[ -f $mas_apps_list ]]; then rm "$mas_apps_list"; fi
  if [[ -f $npm_global_packages_list ]]; then rm "$npm_global_packages_list"; fi
  if [[ -f $pip_packages_list ]]; then rm "$pip_packages_list"; fi
  if [[ -f $ruby_gems_list ]]; then rm "$ruby_gems_list"; fi
}


@test './export-apps-lists.sh is executable' {
  assert_file_executable './export-apps-lists.sh'
}

function invalid_argument_test {
  run ./export-apps-lists.sh "$1" invalid-argument
  assert_output --partial 'Error'
}

function no_argument_test {
  run ./export-apps-lists.sh "$1"
  assert_file_exist "$2"
}

function valid_argument_test {
  run ./export-apps-lists.sh "$1" "$2"
  assert_file_exist "$3"
}

@test './export-apps-lists.sh (no argument)' {
  run ./export-apps-lists.sh
  assert_output --partial 'Error'
}

@test './export-apps-lists.sh <invalid-argument>' {
  eval invalid_argument_test
}

@test './export-apps-lists.sh all' {
  run ./export-apps-lists.sh all
  assert_file_exist "$homebrew_packages_list"
  assert_file_exist "$homebrew_cask_apps_list"
  assert_file_exist "$homebrew_taps_list"
  assert_file_exist "$mas_apps_list"
  assert_file_exist "$npm_global_packages_list"
  assert_file_exist "$pip_packages_list"
  assert_file_exist "$ruby_gems_list"
}

@test './export-apps-lists.sh -d path/to/dir all' {
  run ./export-apps-lists.sh -d "$TEST_TEMP_DIR" all
  assert_file_exist "${TEST_TEMP_DIR}/${homebrew_packages_list}"
  assert_file_exist "${TEST_TEMP_DIR}/${homebrew_cask_apps_list}"
  assert_file_exist "${TEST_TEMP_DIR}/${homebrew_taps_list}"
  assert_file_exist "${TEST_TEMP_DIR}/${mas_apps_list}"
  assert_file_exist "${TEST_TEMP_DIR}/${npm_global_packages_list}"
  assert_file_exist "${TEST_TEMP_DIR}/${pip_packages_list}"
  assert_file_exist "${TEST_TEMP_DIR}/${ruby_gems_list}"
  # to add macprefs
  # to add mackup
}

@test './export-apps-lists.sh help' {
  run ./export-apps-lists.sh help
  assert_output --partial 'usage:'
}

@test './export-apps-lists.sh --help' {
  run ./export-apps-lists.sh --help
  assert_output --partial 'usage:'
}

@test './export-apps-lists.sh brew (no argument)' {
  run ./export-apps-lists.sh brew
  assert_file_exist "$homebrew_packages_list"
  assert_file_exist "$homebrew_cask_apps_list"
  assert_file_exist "$homebrew_taps_list"
}

@test './export-apps-lists.sh brew all' {
  run ./export-apps-lists.sh 'brew' 'all'
  assert_file_exist "$homebrew_packages_list"
  assert_file_exist "$homebrew_cask_apps_list"
  assert_file_exist "$homebrew_taps_list"
}

@test './export-apps-lists.sh brew taps' {
  eval valid_argument_test 'brew' 'taps' "$homebrew_taps_list"
}

@test './export-apps-lists.sh brew packages' {
  eval valid_argument_test 'brew' 'packages' "$homebrew_packages_list"
}

@test './export-apps-lists.sh brew casks' {
  eval valid_argument_test 'brew' 'casks' "$homebrew_cask_apps_list"
}

@test './export-apps-lists.sh brew <invalid-argument>' {
  eval invalid_argument_test 'brew'
}

@test './export-apps-lists.sh ruby (no argument)' {
  eval no_argument_test 'ruby' "$ruby_gems_list"
}

@test './export-apps-lists.sh ruby gems' {
  eval valid_argument_test 'ruby' 'gems' "$ruby_gems_list"
}

@test './export-apps-lists.sh ruby <invalid-argument>' {
  eval invalid_argument_test 'ruby'
}

@test './export-apps-lists.sh mas (no argument)' {
  eval no_argument_test 'mas' "$mas_apps_list"
}

@test './export-apps-lists.sh mas packages' {
  eval valid_argument_test 'mas' 'packages' "$mas_apps_list"
}

@test './export-apps-lists.sh mas <invalid-argument>' {
  eval invalid_argument_test 'mas'
}

@test './export-apps-lists.sh npm (no argument)' {
  eval no_argument_test 'npm' "$npm_global_packages_list"
}

@test './export-apps-lists.sh npm packages' {
  eval valid_argument_test 'npm' 'packages' "$npm_global_packages_list"
}

@test './export-apps-lists.sh npm <invalid-argument>' {
  eval invalid_argument_test 'npm'
}

@test './export-apps-lists.sh pip (no argument)' {
  eval no_argument_test 'pip' "$pip_packages_list"
}

@test './export-apps-lists.sh pip packages' {
  eval valid_argument_test 'pip' 'packages' "$pip_packages_list"
}

@test './export-apps-lists.sh pip <invalid-argument>' {
  eval invalid_argument_test 'pip'
}
