#!/usr/bin/env bash
set -e

# Because `hub` is used, this script expects the following environment variables defined in travis job settings:
# GITHUB_TOKEN - github api token with repo permissions (display value in build log setting: OFF)
# GITHUB_USER - github username that GITHUB_TOKEN is associated with (display value in build log setting: ON)

# COCOAPODS_TRUNK_TOKEN - should be defined in job settings so that we can `pod trunk push`

# GITHUB_RELEASE_DRAFT - set to true for testing. creates a github release draft instead of publishing release.
# defaults to false (ie. publishes release for real)

GITHUB_RELEASE_DRAFT=${GITHUB_RELEASE_DRAFT:-false}


function release_github {
  CHANGELOG="CHANGELOG.md"

  NEW_VERSION=$(grep '^## ' ${CHANGELOG} | awk 'NR==1')
  LAST_VERSION=$(grep '^## ' ${CHANGELOG} | awk 'NR==2')

  DESCRIPTION=$(awk "/^${NEW_VERSION}$/,/^${LAST_VERSION}$/" ${CHANGELOG} | grep -v "^${LAST_VERSION}$")

  if [[ ${GITHUB_RELEASE_DRAFT} == "true" ]]; then
    hub release create -d v${VERSION} -m "Release ${VERSION}" -m "${DESCRIPTION}"
  else
    hub release create v${VERSION} -m "Release ${VERSION}" -m "${DESCRIPTION}"
  fi
}

function release_cocoapods {

  # ---- Optimizely's pods ----
  pods=(OptimizelySDKCore OptimizelySDKShared OptimizelySDKDatafileManager OptimizelySDKEventDispatcher OptimizelySDKUserProfileService OptimizelySDKiOS OptimizelySDKTVOS);
  number_pods=${#pods[@]};

  # ---- push podspecs to cocoapods ----
  # The podspecs need to be pushed in the correct order because of dependencies!
  printf "\n\n11. Pushing podspecs to COCOAPODS.ORG .\n";
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
