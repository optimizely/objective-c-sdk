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
        echo "${curPodSpec} s.version needs to match $VERSION";
        exit 1;
    fi

    pod trunk info $(basename ${curPodSpec} .podspec)

done
