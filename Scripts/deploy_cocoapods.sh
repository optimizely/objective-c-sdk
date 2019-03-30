#!/usr/bin/env bash
set -e

VERSION=${TRAVIS_TAG:1}

podSpecs=(OptimizelySDKCore.podspec \
        OptimizelySDKShared.podspec \
        OptimizelySDKDatafileManager.podspec \
        OptimizelySDKEventDispatcher.podspec \
        OptimizelySDKUserProfileService.podspec \
        OptimizelySDKiOS.podspec \
        OptimizelySDKTVOS.podspec)
numPodSpecs=${#podSpecs[@]};


for (( i = 0; i < ${numPodSpecs}; i++ ))
do
    curPodSpec=${podSpecs[i]}

    echo "Processing: ${curPodSpec}"

    if [ $VERSION != $(pod ipc spec ${curPodSpec} | jq -r .version) ]; then
        echo "${curPodSpec} s.version does not match $VERSION";
        echo "Creating PR to fix bump version..."
        bump_version
        exit 1;
    fi

    pod trunk info $(basename ${curPodSpec} .podspec)

done

function bump_version() {
  mkdir $HOME/objective-c-sdk
  git clone https://$CI_USER_TOKEN@github.com/optimizely/objective-c-sdk.git $HOME/objective-c-sdk
  pushd $HOME/objective-c-sdk
  git checkout -b optibot/versioning_update_$VERSION
  git config user.email "optibot@users.noreply.github.com"
  git config user.name "optibot"

  pushd Scripts && ./update_version.sh $VERSION && popd

  git commit -m "ci(travis): automated versioning update" -a
  git push https://$CI_USER_TOKEN@github.com/optimizely/objective-c-sdk.git optibot/versioning_update_$VERSION

  # this creates the PR in github
  PR_URL=$(hub pull-request --no-edit)
  echo "MERGE THIS PR to fix versioning issue: $PR_URL"
  echo "then delete git tag and repush git tag to trigger deploy again"
  popd
}
