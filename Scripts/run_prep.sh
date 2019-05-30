#!/usr/bin/env bash
set -e

# Because `hub` is used, this script expects the following environment variables defined in travis job settings:
# GITHUB_TOKEN - github api token with repo permissions (display value in build log setting: OFF)
# GITHUB_USER - github username that GITHUB_TOKEN is associated with (display value in build log setting: ON)

# Additionally, it needs the following environment variables:
# VERSION - defined in .travis.yml

# Variables starting with TRAVIS_ are default environment variables available to all Travis CI builds

COLOR_RESET='\033[0m'
COLOR_MAGENTA='\033[0;35m'
COLOR_CYAN='\033[0;36m'
MYREPO=${HOME}/workdir/${TRAVIS_REPO_SLUG}
AUTOBRANCH=${GITHUB_USER}/prepareRelease${VERSION}
BUILD_OUTPUT=/tmp/build.out
touch $BUILD_OUTPUT

function prep_workspace {
  rm -rf ${MYREPO}
  mkdir -p ${MYREPO}
  git clone -b ${TRAVIS_BRANCH} https://${GITHUB_TOKEN}@github.com/${TRAVIS_REPO_SLUG} ${MYREPO}
  cd ${MYREPO}
  git checkout -b ${AUTOBRANCH}
}

dump_output() {
  echo "last 100 lines of output:"
  tail -100 $BUILD_OUTPUT
}

function error_handler() {
  echo "ERROR: An error was encountered."
  dump_output
  exit 1
}

function do_stuff {
  # keepalive for Travis
  while :; do sleep 10; echo -n .; done &
  trap "kill $!" EXIT
  trap 'error_handler' ERR

  myscripts=( "update_version.sh ${VERSION}" "build_all.sh" "unexported_symbols/unexported_symbols.sh" "test_all.sh" )
  for i in "${myscripts[@]}"; do
    echo -n "${i} "
    Scripts/${i} >> $BUILD_OUTPUT 2>&1
    echo
  done

  dump_output
  kill $! && trap " " EXIT
}

function push_changes {
  git config user.email "optibot@users.noreply.github.com"
  git config user.name "${GITHUB_USER}"
  git add --all && git commit -m "ci(travis): auto release prep for $VERSION"
  git push https://${GITHUB_TOKEN}@github.com/${TRAVIS_REPO_SLUG} ${AUTOBRANCH}
  PR_URL=$(hub pull-request --no-edit -b ${TRAVIS_BRANCH})
  echo -e "${COLOR_CYAN}ATTENTION:${COLOR_RESET} review and merge ${COLOR_CYAN}${PR_URL}${COLOR_RESET}"
  echo "then to release to cocoapods use Travis CI's Trigger build with the following payload:"
  echo -e "${COLOR_MAGENTA}env:${COLOR_RESET}"
  echo -e "${COLOR_MAGENTA}  - RELEASE=true${COLOR_RESET}"
}

function main {
  prep_workspace
  time do_stuff
  push_changes
}

main
