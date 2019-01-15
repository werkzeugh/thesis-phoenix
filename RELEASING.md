# Releasing Thesis

#### Preflight sanity checks

1. make sure you're in the project root directory
1. switch to the `master` branch: `git checkout master`
1. you have all latest updates: `git pull`
1. you have no changes to push and no staged changes.
1. run `./bin/ci` and ensure all tests pass

#### Pushing a new release

1. run `yarn webpack` to build the static css/js files
1. run `mix hex.user whoami`
1. check if your hex user is in the [owner's list](https://hex.pm/packages/thesis) of the package (if not, you will need to get added as an owner)
1. update the version number in:

- `./mix.exs`
- `./package.json`
- `./README_INSTALL.md`
- `./README.md` (also update the changelog)

1. generate docs: `mix docs`
1. run `mix hex.publish`

#### Verify & Announce

1. you win.
