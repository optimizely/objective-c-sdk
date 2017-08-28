#!/bin/bash
################################################################
#    buildall.sh
# * Not really in production, but a personal script written quickly
# to automate building all the objective-c-sdk workspace schemes .
# * There aren't any tempfiles .  Copied and pasted some stuff
# from our unexported_symbols.sh script.
################################################################
set -e

cleanup() {
  rm -f "${tempfiles[@]}"
}
trap cleanup 0

error() {
  local lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "${message}" ]] ; then
    echo "Error on line ${lineno}: ${message}; status ${code}"
  else
    echo "Error on line ${lineno}; status ${code}"
  fi
  exit "${code}"
}
trap 'error ${LINENO}' ERR

main() {
  action="build"

  if [[ "$#" == "1" ]]; then
    # TODO: This isn't the best, but you can supply "clean" to our command.
    action="$1"
  fi;
  # TODO: We'll need to specify certificate for the app builds.
  #xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelyiOSDemoApp -configuration Release "${action}"
  #xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelyTVOSDemoApp -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKCoreiOS -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKCoreTVOS -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKDatafileManageriOS -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKDatafileManagerTVOS -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKEventDispatcheriOS -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKEventDispatcherTVOS -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKiOS -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKiOS-Universal -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKiOSUniversal -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKSharediOS -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKSharedTVOS -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKTVOS -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKTVOS-Universal -configuration Release "${action}"
  # Xcode IDE is happy with OptimizelySDKTVOSUniversal , we don't know what's up with our *.sh .
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKTVOSUniversal -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKUserProfileServiceiOS -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKUserProfileServiceTVOS -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme Pods-OptimizelyiOSDemoApp -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme Pods-OptimizelySDKCoreiOSTests -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme Pods-OptimizelySDKCoreTVOSTests -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme Pods-OptimizelySDKDatafileManageriOSTests -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme Pods-OptimizelySDKDatafileManagerTVOSTests -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme Pods-OptimizelySDKEventDispatcheriOSTests -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme Pods-OptimizelySDKEventDispatcherTVOSTests -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme Pods-OptimizelySDKiOSTests -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme Pods-OptimizelySDKSharediOSTests -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme Pods-OptimizelySDKSharedTVOSTests -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme Pods-OptimizelySDKTVOSTests -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme Pods-OptimizelySDKUserProfileServiceiOSTests -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme Pods-OptimizelySDKUserProfileServiceTVOSTests -configuration Release "${action}"
  xcodebuild -workspace OptimizelySDK.xcworkspace -scheme Pods-OptimizelyTVOSDemoApp -configuration Release "${action}"
}

main

