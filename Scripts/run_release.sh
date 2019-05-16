#!/usr/bin/env bash
set -e

# Because `hub` is used, this script expects the following environment variables defined in travis job settings:
# GITHUB_TOKEN - github api token with repo permissions (display value in build log setting: OFF)
# GITHUB_USER - github username that GITHUB_TOKEN is associated with (display value in build log setting: ON)

# COCOAPODS_TRUNK_TOKEN - should be defined in job settings so that we can `pod trunk push`

function release_github {
  CHANGELOG="CHANGELOG.md"

  # check that CHANGELOG.md has been updated
  NEW_VERSION_CHECK=$(grep '^## \d\+\.\d\+.\d\+' ${CHANGELOG} | awk 'NR==1' | tr -d '# ')
  if [[ ${NEW_VERSION_CHECK} != ${VERSION} ]]; then
    echo "ERROR: ${CHANGELOG} has not been updated yet."
    exit 1
  fi

  NEW_VERSION=$(grep '^## \d\+\.\d\+.\d\+' ${CHANGELOG} | awk 'NR==1')
  LAST_VERSION=$(grep '^## \d\+\.\d\+.\d\+' ${CHANGELOG} | awk 'NR==2')

  DESCRIPTION=$(awk "/^${NEW_VERSION}$/,/^${LAST_VERSION}$/" ${CHANGELOG} | grep -v "^${LAST_VERSION}$")

  hub release create v${VERSION} -m "Release ${VERSION}" -m "${DESCRIPTION}"

}

function release_cocoapods {

  # ---- Optimizely's pods ----
  pods=(OptimizelySDKCore OptimizelySDKShared OptimizelySDKDatafileManager OptimizelySDKEventDispatcher OptimizelySDKUserProfileService OptimizelySDKiOS OptimizelySDKTVOS);
  number_pods=${#pods[@]};

  # ---- push podspecs to cocoapods ----
  # The podspecs need to be pushed in the correct order because of dependencies!
  printf "\n\nPushing podspecs to COCOAPODS.ORG .\n";
  for (( i = 0; i < ${number_pods}; i++ ));
  do
    podname=${pods[i]};
    printf "Pushing the ${podname} pod to COCOAPODS.ORG .\n"
    pod trunk push --allow-warnings ${podname}.podspec
    pod update
  done

}

function main {
  release_github
  release_cocoapods
}

main
