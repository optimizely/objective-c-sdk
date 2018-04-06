#!/bin/bash

# This script guides you through all the steps needed to do a new release.
# The script assumes you are on the master branch and are in the Script folder.
# The script does the following:

# 0. If revised or additional third-party dependencies are added (aside from
# OPTLYJSONModel, MurmurHash3, or OPTLYFMDB), run the unexported_symbols.sh script to create
# a new unexported_symbols.txt, which hides all third-party dependency symbols.
# 1. Reminder prompt to update CHANGELOG.md .
# 2. Reminder prompt to update project Build Settings with proper OPTIMIZELY_SDK_VERSION information.
# 3. Get OPTIMIZELY_SDK_VERSION from the Xcode build settings.
# 4. Build the universal frameworks.
# 5. Update podspec files with the correct version number.
# 6. Verify podspec files.
# 8. git tag the release.
# 9. git push the tag.
# 10. Confirm if pod trunk session is open.
# 11. pod trunk push all the podspecs.

# The ideal scenario will be that you have just merged a #.#.# P.R. onto a #.#.x
# branch and the P.R. itself generated new universal frameworks and updated
# its podspecs .  The P.R. should also have updated OPTIMIZELY_SDK_VERSION .
# You will connect to the Scripts subdirectory and run "sh ./release.sh" .
# If you don't have experience with the script, have an experienced developer
# monitor and assist the release with you.  Only OPTIMIZELY.COM developers
# with access to Optimizely's COCOAPODS.ORG account can upload to COCOAPODS.ORG .
# The release.sh won't work for anyone else.

# Change to the project root folder
pushd ..
printf "Current working directory: $PWD.\n\n";

# 1. Prompt a reminder to update the CHANGELOG.md
read  -n 1 -p "1. Have you updated the CHANGELOG.md ? (Please check the contents and formatting.) [y/n] $cr " changelog_update;
if [ "$changelog_update" != "y" ]; then
    printf "\nUpdate the CHANGELOG.md before proceeding!\n"
    exit 1
fi;

# 2. Prompt a reminder to update Build Setting version number. Make sure this is done in
# the Build Settings at the Project level (not at the Target level) so that all Targets will
# inherit the version number.
printf "\n\n";
printf "2. Have you updated OPTIMIZELY_SDK_VERSION in Optimizely frameworks project Build Settings?\n";
printf "This should done at Project level (not Target level) for inheritance.\n"
read  -n 1 -p "[y/n] $cr? " build_setting_update;
if [ "$build_setting_update" != "y" ]; then
    printf "\nUpdate OPTIMIZELY_SDK_VERSION in Optimizely frameworks project Build Settings!\n"
    exit 1
fi;

## ---- Extract OPTIMIZELY_SDK_VERSION from Xcode Build Settings. ----
printf "\n\n3. Extracting OPTIMIZELY_SDK_VERSION from Xcode Build Settings.\n\n";
OPTIMIZELY_SDK_VERSION=$(Xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKCoreiOS -showBuildSettings | sed -n 's/OPTIMIZELY_SDK_VERSION = \(.*\)/\1/p' | sed 's/ //g');
echo "OPTIMIZELY_SDK_VERSION = $OPTIMIZELY_SDK_VERSION";

# Make sure that OPTIMIZELY_SDK_VERSION looks correct!
printf "\n"
read  -n 1 -p "Does OPTIMIZELY_SDK_VERSION look correct? [y/n] $cr? " version_valid;
if [ "$version_valid" != "y" ]; then
    printf "\nCorrect OPTIMIZELY_SDK_VERSION in the Xcode Build Settings before proceeding!\n"
    exit 1
fi;

# ---- Build universal frameworks ----
printf "\n\n4. Building universal frameworks.\n\n"
printf "Build universal frameworks? (We recommend no, not here.)\n"
printf "(You should have done this earlier in the #.#.# branch that P.R.'s on a #.#.x branch.)"
read  -n 1 -p "[y/n] $cr? " build_universal;
if [ "$build_universal" == "y" ]; then
    Xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKiOS-Universal -configuration Release
    Xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKTVOS-Universal -configuration Release
    printf "\nPlease commit your change.\n"
    exit 1
fi

# ---- Optimizely's pods ----
pods=(OptimizelySDKCore OptimizelySDKShared OptimizelySDKDatafileManager OptimizelySDKEventDispatcher OptimizelySDKUserProfileService OptimizelySDKiOS OptimizelySDKTVOS);
number_pods=${#pods[@]};

# ---- Update podspec files ----
printf "\n\n5. Update *.podspec files to ${OPTIMIZELY_SDK_VERSION}?  (We recommend no, not here.)\n"
printf "(You should have done this earlier in the #.#.# branch that P.R.'s on a #.#.x branch.)\n"
read  -n 1 -p "[y/n] $cr? " update_podspecs;
if [ "$update_podspecs" == "y" ]; then
    for (( i = 0; i < ${number_pods}; i++ ));
    do
        podname1=${pods[i]};
        printf "Updating ${podname1}.podspec to ${OPTIMIZELY_SDK_VERSION}.\n"
        sed -e "s/s\.version[ ]*=[ ]*\".*\"/s.version                 = \"${OPTIMIZELY_SDK_VERSION}\"/g" ${podname1}.podspec > ${podname1}.podspec.bak;
        mv ${podname1}.podspec.bak ${podname1}.podspec;
        for (( j = 0; j < ${number_pods}; j++ ));
        do
            podname2=${pods[j]};
            sed -e "s/s\.dependency \'${podname2}\', \'.*\'/s\.dependency \'${podname2}\', \'${OPTIMIZELY_SDK_VERSION}\'/g" ${podname1}.podspec > ${podname1}.podspec.bak;
            mv ${podname1}.podspec.bak ${podname1}.podspec;
        done
    done
    printf "\nPlease commit your change.\n"
    exit 1
fi

# Make sure that all the podspec files are as expected!
open -a Xcode *podspec;
printf "\nPlease visually inspect all podspec files."
read  -n 1 -p "Do all podspec files look correct? [y/n] $cr? " podspec_valid;
if [ "$podspec_valid" != "y" ]; then
    printf "\nCorrect the podspec files before proceeding!\n"
    exit 1
fi;

# ---- Verify podspecs ----
printf "\n\n"
read  -n 1 -p "6. Verify all podspecs? Skip if this has already been done. [y/n] $cr? " verify_podspec;
if [ "$verify_podspec" == "y" ]; then
    printf "\nVerifying podspecs.\n";
    for (( i = 0; i < ${number_pods}; i++ ));
    do
        podname=${pods[i]};
        printf "Verifying ${podname}.podspec .\n"
        pod spec lint ${podname}.podspec
    done;
fi;

printf "\n"
printf "Are all podspecs valid? (If none of the pods have been pushed to COCOAPODS.ORG ,\n"
printf "you can ignore the dependency errors: None of your spec sources contain a spec\n"
printf "satisfying the dependency.)\n"
read  -n 1 -p "[y/n] $cr? " podspec_valid;
if [ "$podspec_valid" != "y" ]; then
    printf "\nCorrect the podspec(s) before proceeding. Delete tag and retag the fixed podspec.\n"
    exit 1
fi;

# ---- git tag ----
printf "\n\n8. Tagging release.\n";
printf "Tag release? (We recommend no, not here.)\n"
printf "(It's better to use GITHUB.COM's 'Draft a new release' UI on\n"
printf "https://github.com/optimizely/objective-c-sdk/releases\n"
printf "to create a tag and release message.  Make sure to choose\n"
printf "the correct 'Target' branch.  We expect you are tagging a commit\n"
printf "on a #.#.x branch.)\n"
read  -n 1 -p "[y/n] $cr? " tag_release;
if [ "$tag_release" == "y" ]; then
    printf "Tagging $OPTIMIZELY_SDK_VERSION\n";
    git tag -a $OPTIMIZELY_SDK_VERSION -m "Release $OPTIMIZELY_SDK_VERSION";
    printf "\n\n9. Pushing git tag.\n"
    git push origin $OPTIMIZELY_SDK_VERSION --verbose;
fi;

# ---- Make sure you have a Cocoapod session running ----
printf "\n\n10. Verify Cocoapod trunk session.\n";
pod trunk me;

read  -n 1 -p "Do you have a valid Cocoapod session running? [y/n] $cr? " cocoapod_session;
if [ "$cocoapod_session" != "y" ]; then
    printf "\nCreate a Cocoapod trunk session: https://guides.cocoapods.org/making/getting-setup-with-trunk.html.\n"
    printf "Use 'pod trunk register' command to create your first COCOAPODS.ORG session\n"
    printf "or renew an expired COCOAPODS.ORG session .  See:"
    printf "https://guides.cocoapods.org/terminal/commands.html#pod_trunk_register .\n"
    exit 1
fi;

# ---- push podspecs to cocoapods ----
# The podspecs need to be pushed in the correct order because of dependencies!
printf "\n\n11. Pushing podspecs to COCOAPODS.ORG .\n";
for (( i = 0; i < ${number_pods}; i++ ));
do
    podname=${pods[i]};
    printf "Pushing the ${podname} pod to COCOAPODS.ORG .\n"
    pod trunk push ${podname}.podspec
    pod update ${podname}
done
