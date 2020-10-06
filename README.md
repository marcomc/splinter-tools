[![Build Status](https://api.travis-ci.com/marcomc/splinter-tools.png)](https://www.travis-ci.com/github/marcomc/splinter-tools/builds)
# splinter-tools
Additional tools for Splinter provisioning

# Unit testing

BATS scripts are contained in './test'

    bats ./test

## Setup

### install bats-core ('/usr/local/bin/bats')
brew install bats-core
### add submodules to a project
    git submodule add https://github.com/ztombol/bats-support test/test_helper/bats-support
    git submodule add https://github.com/bats-core/bats-assert  test/test_helper/bats-assert
    git submodule add https://github.com/bats-core/bats-file  test/test_helper/bats-file
    git commit -m 'Add bats-support/assert/file libraries'

### Load a library from the 'test_helper' directory.
    # file: test/test_helper.sh
    #   $1 - name of library to load
    load_lib() {
      local name="$1"
      load "test_helper/${name}/load"
    }

    # load a library with only its name, instead of having to type the entire installation path.

    load_lib bats-support
    load_lib bats-assert
    load_lib bats-file

### Reference: official BATS documentation

* [Shared documentation](https://github.com/ztombol/bats-docs)
* [bats-core](https://github.com/bats-core/bats-core)
* [bats-support](https://github.com/bats-core/bats-support)
* [bats-assert](https://github.com/bats-core/bats-assert)
* [bats-file](https://github.com/bats-core/bats-file)
