#!/bin/bash

# update_version.sh
#
# This script consistently updates the SDK version numbers in several places:
# 1. {XcodeProject}/{XcodeProject}.xcodeproj/project.pbxproj
# 2. {XcodeProject}.podspec
#
# Usage:
#  $ ./update_version.sh [releaseSDKVersion]
#


#----------------------------------------------------------------------------------
# set the release SDK version
#----------------------------------------------------------------------------------
if [ "$#" -eq  "1" ];
then
    releaseSDKVersion="$1"
else
read  -p "Enter the new SDK release version (ex: 2.1.4): " releaseSDKVersion;
fi

varComps=( ${releaseSDKVersion//./ } )

if (( ${#varComps[@]} != 3 )); then
    printf "\n[ERROR] Invalid target version number: ${releaseSDKVersion} \n"
    exit 1
fi

vMajor=${varComps[0]}
vMinor=${varComps[1]}
vPatch=${varComps[2]}

printf "\nRelease SDK Version: ${releaseSDKVersion} \n"

cd "$(dirname $0)/.."

#----------------------------------------------------------------------------------
# 1. update the SDK version in all xcode project settings
#----------------------------------------------------------------------------------
# SDK submodules + universal
mods=(OptimizelySDKCore \
    OptimizelySDKShared \
    OptimizelySDKDatafileManager \
    OptimizelySDKEventDispatcher \
    OptimizelySDKUserProfileService \
    OptimizelySDKiOS \
    OptimizelySDKTVOS \
    OptimizelySDKUniversal)
numMods=${#mods[@]}

printf "\n\nReplacing OPTIMIZELY_SDK_VERSION in Xcode Build Settings to the target version.\n"

for (( i = 0; i < ${numMods}; i++ ))
do
    curMod=${mods[i]}
    curPbxProjPath=${curMod}/${curMod}.xcodeproj/project.pbxproj
    printf "\t[${curMod}] Updating .pbxproj to ${releaseSDKVersion}.\n"

    sed -i '' -e "s/\(OPTIMIZELY_SDK_VERSION_MAJOR[ ]*\)=.*;/\1= ${vMajor};/g" ${curPbxProjPath}
    sed -i '' -e "s/\(OPTIMIZELY_SDK_VERSION_MINOR[ ]*\)=.*;/\1= ${vMinor};/g" ${curPbxProjPath}
    sed -i '' -e "s/\(OPTIMIZELY_SDK_VERSION_PATCH[ ]*\)=.*;/\1= ${vPatch};/g" ${curPbxProjPath}
done

printf "Verifying OPTIMIZELY_SDK_VERSION from Xcode Build Settings.\n";

for (( i = 0; i < ${numMods}; i++ ))
do
    curMod=${mods[i]}
    curProjPath=${curMod}/${curMod}.xcodeproj

    OPTIMIZELY_SDK_VERSION=$(Xcodebuild -project ${curProjPath} -showBuildSettings | sed -n 's/OPTIMIZELY_SDK_VERSION = \(.*\)/\1/p' | sed 's/ //g');

    if [ "${OPTIMIZELY_SDK_VERSION}" == "${releaseSDKVersion}" ]
    then
        printf "\t[${curMod}] OPTIMIZELY_SDK_VERSION in xcode settings verified: ${releaseSDKVersion}/${OPTIMIZELY_SDK_VERSION}\n"
    else
        printf "\n[ERROR][${curMod}] OPTIMIZELY_SDK_VERSION mismatch: (releaseSDKVersion/OPTIMIZELY_SDK_VERSION) = ${releaseSDKVersion}/${OPTIMIZELY_SDK_VERSION}\n";
       exit 1
    fi

done


#----------------------------------------------------------------------------------
# 2. update the SDK version in all podspecs
#----------------------------------------------------------------------------------
podSpecs=(OptimizelySDKCore.podspec \
        OptimizelySDKShared.podspec \
        OptimizelySDKDatafileManager.podspec \
        OptimizelySDKEventDispatcher.podspec \
        OptimizelySDKUserProfileService.podspec \
        OptimizelySDKiOS.podspec \
        OptimizelySDKTVOS.podspec)
numPodSpecs=${#podSpecs[@]};

printf "\n\nReplacing all versions in *.podspec files\n"

for (( i = 0; i < ${numPodSpecs}; i++ ));
do
    curPodSpec=${podSpecs[i]}

    printf "\t[${curPodSpec}] Updating podspec to ${releaseSDKVersion}.\n"
    sed -i '' -e "s/\(s\.version[ ]*\)=[ ]*\".*\"/\1= \"${releaseSDKVersion}\"/g" ${curPodSpec}
    sed -i '' -e "s/\(s\.dependency[ ]*[\'\"]OptimizelySDK.*[\'\"].*\,\)[ ]*[\'\"].*[\'\"]/\1 \"${releaseSDKVersion}\"/g" ${curPodSpec}
done

# pod-spec-lint cannot be run here due to dependency issues
# all podspecs will be validated anyway when uploading to CocoaPods repo

printf "Verifying *.podspec files\n"

countChanges=0

for (( i = 0; i < ${numPodSpecs}; i++ ))
do
    curPodSpec=${podSpecs[i]}

    vm=$(sed -n "s/s\.version.*=.*\"\(.*\)\"/\1/p" ${curPodSpec} | sed "s/ //g" )
    if [ "${vm}" == "${releaseSDKVersion}" ]; then countChanges=$(( countChanges + 1 )); fi

    deps=$(sed -n "s/s\.dependency.*OptimizelySDK.*\"\(.*\)\"/\1/p" ${curPodSpec} | sed "s/ //g" )
    deps=( ${deps//\n/ } )
    for (( j = 0; j < ${#deps[@]}; j++ )); do
        if [ "${deps[j]}" == "${releaseSDKVersion}" ]; then countChanges=$(( countChanges + 1 )); fi
    done

    printf "\t[${curPodSpec}] Verified podspec: ${releaseSDKVersion}\n"
done

# check total 17 (= 7 + 10) places replaced
expTotalCount=17
if (( ${countChanges} == ${expTotalCount} ))
then
    printf "Verified successfully! (podspec version updated in ${expTotalCount} places) \n"
else
    printf "\n[ERROR] podspec version update failed (count=${countChanges}). check it out! \n"
    exit 1
fi

printf "\n\n[SUCCESS] All release-skd-version settings have been updated successfully!\n\n\n"
