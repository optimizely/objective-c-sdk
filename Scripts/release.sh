#!/bin/bash

# This script guides you through all the steps needed to do a new release.
# The script does the following:

# 1. Reminder prompt to update the CHANGELOG.
# 2. Reminder prompt to update the Build Settings with the proper version number for each module that requires a version bump.
# 3. Gets the version numbers from the XCode build settings.
# 4. Update podspec files with the correct version number
# 5. Commit and push the version bump changes to devel.
# 6. Prompt to merge devel onto master via GitHub UI.
# 7. git tag all the modules.
# 8. git push all tags.
# 9. Verify podspec files.
# 10. Confirm if pod trunk session is open.
# 11. pod trunk push all the podspecs.


# Change to the project root folder
(cd /Users/aluong/src/objective-c-sdk-release;
printf "Current working directory: $PWD\n\n";

# ---- Before running this script!!! ----
#1. Update the CHANGELOG
read  -n 1 -p "1. Have you updated the CHANGELOG [y/n] $cr? " changelog_update;
if [ "$changelog_update" != "y" ]; then
    printf "\nUpdate the CHANGELOG before proceeding!!\n"
    exit 1
fi;

#2. Update Build Setting version number. Make sure this is done in the Build Settings at the Project level (not at the Target level) so that all Targets will inherit the version number.
printf "\n\n";
read  -n 1 -p "2. Have you updated the version number for all frameworks in the Xcode Build Settings? Make sure this is done in the Build Settings at the Project level (not at the Target level) so that all Targets will inherit the version number. [y/n] $cr? " build_setting_update;
if [ "$build_setting_update" != "y" ]; then
    printf "\nUpdate the version numbers for all frameworks in the Xcode Build Settings before proceeding!!\n"
    exit 1
fi;

## ---- Extract version numbers from XCode build settings ----
printf "\n\n3. Getting new versions from XCode Build Settings...\n\n";

schemes=(OptimizelySDKiOS OptimizelySDKTVOS OptimizelySDKCoreiOS OptimizelySDKSharediOS OptimizelySDKEventDispatcheriOS OptimizelySDKDatafileManageriOS OptimizelySDKUserProfileiOS);

# OPTIMIZELY_SDK_CORE_VERSION
OPTIMIZELY_SDK_CORE_VERSION=$(xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKCoreiOS -showBuildSettings | sed -n 's/OPTIMIZELY_SDK_CORE_VERSION = \(.*\)/\1/p' | sed 's/ //g');
echo "OPTIMIZELY_SDK_CORE_VERSION = $OPTIMIZELY_SDK_CORE_VERSION";

# OPTIMIZELY_SDK_SHARE_VERSION
OPTIMIZELY_SDK_SHARED_VERSION=$(xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKSharediOS -showBuildSettings | sed -n 's/OPTIMIZELY_SDK_SHARED_VERSION = \(.*\)/\1/p' | sed 's/ //g');
echo "OPTIMIZELY_SDK_SHARED_VERSION = $OPTIMIZELY_SDK_SHARED_VERSION";

# OPTIMIZELY_SDK_DATAFILE_MANAGER_VERSION
OPTIMIZELY_SDK_DATAFILE_MANAGER_VERSION=$(xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKDatafileManageriOS -showBuildSettings | sed -n 's/OPTIMIZELY_SDK_DATAFILE_MANAGER_VERSION = \(.*\)/\1/p' | sed 's/ //g');
echo "OPTIMIZELY_SDK_DATAFILE_MANAGER_VERSION = $OPTIMIZELY_SDK_DATAFILE_MANAGER_VERSION";

# OPTIMIZELY_SDK_EVENT_DISPATCHER_VERSION
OPTIMIZELY_SDK_EVENT_DISPATCHER_VERSION=$(xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKEventDispatcheriOS -showBuildSettings | sed -n 's/OPTIMIZELY_SDK_EVENT_DISPATCHER_VERSION = \(.*\)/\1/p' | sed 's/ //g');
echo "OPTIMIZELY_SDK_EVENT_DISPATCHER_VERSION = $OPTIMIZELY_SDK_EVENT_DISPATCHER_VERSION";

# OPTIMIZELY_SDK_USER_PROFILE_VERSION
OPTIMIZELY_SDK_USER_PROFILE_VERSION=$(xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKUserProfileiOS -showBuildSettings | sed -n 's/OPTIMIZELY_SDK_USER_PROFILE_VERSION = \(.*\)/\1/p' | sed 's/ //g');
echo "OPTIMIZELY_SDK_USER_PROFILE_VERSION = $OPTIMIZELY_SDK_USER_PROFILE_VERSION";

# OPTIMIZELY_SDK_iOS_VERSION
OPTIMIZELY_SDK_iOS_VERSION=$(xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKiOS -showBuildSettings | sed -n 's/OPTIMIZELY_SDK_iOS_VERSION = \(.*\)/\1/p' | sed 's/ //g');
echo "OPTIMIZELY_SDK_iOS_VERSION = $OPTIMIZELY_SDK_iOS_VERSION";

# OPTIMIZELY_SDK_TVOS_VERSION
OPTIMIZELY_SDK_TVOS_VERSION=$(xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKTVOS -showBuildSettings | sed -n 's/OPTIMIZELY_SDK_TVOS_VERSION = \(.*\)/\1/p' | sed 's/ //g');
echo "OPTIMIZELY_SDK_TVOS_VERSION = $OPTIMIZELY_SDK_TVOS_VERSION";

# make sure that all the version numbers are as expected!
printf "\n"
read  -n 1 -p "Do all the version numbers look correct? [y/n] $cr? " versions_valid;
if [ "$versions_valid" != "y" ]; then
    printf "\nCorrect the version numbers in the Xcode Build Settings before proceeding!!\n"
    exit 1
fi;

# ---- Update podspec files ----
printf "\n\n4. Updating podspec files with the new version numbers...\n\n"
# Update the OPTIMIZELY_SDK_CORE_VERSION:
# OptimizelySDKCore.podspec
printf "Updating OptimizelySDKCore to $OPTIMIZELY_SDK_CORE_VERSION in...\n"
printf "OptimizelySDKCore.podspec\n"
sed -e "s/s\.version[ ]*=[ ]*\".*\"/s.version                 = \"$OPTIMIZELY_SDK_CORE_VERSION\"/g" OptimizelySDKCore.podspec > OptimizelySDKCore.podspec.bak;
mv OptimizelySDKCore.podspec.bak OptimizelySDKCore.podspec;
# OptimizelySDKShared.podspec
printf "OptimizelySDKShared.podspec\n\n"
sed -e "s/s\.dependency \'OptimizelySDKCore\', \'.*\'/s\.dependency \'OptimizelySDKCore\', \'$OPTIMIZELY_SDK_CORE_VERSION\'/g" OptimizelySDKShared.podspec > OptimizelySDKShared.podspec.bak;
mv OptimizelySDKShared.podspec.bak OptimizelySDKShared.podspec;

# Update the OPTIMIZELY_SDK_SHARED_VERSION:
# OptimizelySDKShared.podspec
printf "Updating OptimizelySDKShared to $OPTIMIZELY_SDK_SHARED_VERSION in...\n"
printf "OptimizelySDKShared.podspec\n"
sed -e "s/s\.version[ ]*=[ ]*\".*\"/s.version                 = \"$OPTIMIZELY_SDK_SHARED_VERSION\"/g" OptimizelySDKShared.podspec > OptimizelySDKShared.podspec.bak;
mv OptimizelySDKShared.podspec.bak OptimizelySDKShared.podspec;
# OptimizelySDKEventDispatcher.podspec
printf "OptimizelySDKEventDispatcher.podspec\n"
sed -e "s/s\.dependency \'OptimizelySDKShared\', \'.*\'/s\.dependency \'OptimizelySDKShared\', \'$OPTIMIZELY_SDK_SHARED_VERSION\'/g" OptimizelySDKEventDispatcher.podspec > OptimizelySDKEventDispatcher.podspec.bak;
mv OptimizelySDKEventDispatcher.podspec.bak OptimizelySDKEventDispatcher.podspec;
# OptimizelySDKDatafileManager.podspec
printf "OptimizelySDKDatafileManager.podspec\n"
sed -e "s/s\.dependency \'OptimizelySDKShared\', \'.*\'/s\.dependency \'OptimizelySDKShared\', \'$OPTIMIZELY_SDK_SHARED_VERSION\'/g" OptimizelySDKDatafileManager.podspec > OptimizelySDKDatafileManager.podspec.bak;
mv OptimizelySDKDatafileManager.podspec.bak OptimizelySDKDatafileManager.podspec;
# OptimizelySDKUserProfile.podspec
printf "OptimizelySDKUserProfile.podspec\n\n"
sed -e "s/s\.dependency \'OptimizelySDKShared\', \'.*\'/s\.dependency \'OptimizelySDKShared\', \'$OPTIMIZELY_SDK_SHARED_VERSION\'/g" OptimizelySDKUserProfile.podspec > OptimizelySDKUserProfile.podspec.bak;
mv OptimizelySDKUserProfile.podspec.bak OptimizelySDKUserProfile.podspec;

# Update the OPTIMIZELY_SDK_iOS_VERSION:
# OptimizelySDKiOS.podspec
printf "Updating OptimizelySDKiOS to $OPTIMIZELY_SDK_iOS_VERSION in...\n"
printf "OptimizelySDKiOS.podspec\n\n"
sed -e "s/s\.version[ ]*=[ ]*\".*\"/s.version                 = \"$OPTIMIZELY_SDK_iOS_VERSION\"/g" OptimizelySDKiOS.podspec > OptimizelySDKiOS.podspec.bak;
mv OptimizelySDKiOS.podspec.bak OptimizelySDKiOS.podspec;

# Update the OPTIMIZELY_SDK_TVOS_VERSION:
# OptimizelySDKTVOS.podspec
printf "Updating OptimizelySDKTVOS to $OPTIMIZELY_SDK_TVOS_VERSION in...\n"
printf "OptimizelySDKTVOS.podspec\n\n"
sed -e "s/s\.version[ ]*=[ ]*\".*\"/s.version                 = \"$OPTIMIZELY_SDK_TVOS_VERSION\"/g" OptimizelySDKTVOS.podspec > OptimizelySDKTVOS.podspec.bak;
mv OptimizelySDKTVOS.podspec.bak OptimizelySDKTVOS.podspec;

# Update the OPTIMIZELY_SDK_EVENT_DISPATCHER_VERSION:
# OptimizelySDKEventDispatcher.podspec
printf "Updating OptimizelySDKEventDispatcher to $OPTIMIZELY_SDK_EVENT_DISPATCHER_VERSION in\n"
printf "OptimizelySDKEventDispatcher.podspec\n"
sed -e "s/s\.version[ ]*=[ ]*\".*\"/s.version                 = \"$OPTIMIZELY_SDK_EVENT_DISPATCHER_VERSION\"/g" OptimizelySDKEventDispatcher.podspec > OptimizelySDKEventDispatcher.podspec.bak;
mv OptimizelySDKEventDispatcher.podspec.bak OptimizelySDKEventDispatcher.podspec;
# OptimizelySDKiOS.podspec
printf "OptimizelySDKiOS.podspec\n"
sed -e "s/s\.dependency \'OptimizelySDKEventDispatcher\', \'.*\'/s\.dependency \'OptimizelySDKEventDispatcher\', \'$OPTIMIZELY_SDK_EVENT_DISPATCHER_VERSION\'/g" OptimizelySDKiOS.podspec > OptimizelySDKiOS.podspec.bak
mv OptimizelySDKiOS.podspec.bak OptimizelySDKiOS.podspec;
# OptimizelySDKTVOS.podspec
printf "OptimizelySDKTVOS.podspec\n\n"
sed -e "s/s\.dependency \'OptimizelySDKEventDispatcher\', \'.*\'/s\.dependency \'OptimizelySDKEventDispatcher\', \'$OPTIMIZELY_SDK_EVENT_DISPATCHER_VERSION\'/g" OptimizelySDKTVOS.podspec > OptimizelySDKTVOS.podspec.bak;
mv OptimizelySDKTVOS.podspec.bak OptimizelySDKTVOS.podspec;

# Update the OPTIMIZELY_SDK_DATAFILE_MANAGER_VERSION:
# OptimizelySDKDatafileManager.podspec
printf "Updating OptimizelySDKDatafileManager to $OPTIMIZELY_SDK_DATAFILE_MANAGER_VERSION in...\n"
printf "OptimizelySDKDatafileManager.podspec\n"
sed -e "s/s\.version[ ]*=[ ]*\".*\"/s.version                 = \"$OPTIMIZELY_SDK_DATAFILE_MANAGER_VERSION\"/g" OptimizelySDKDatafileManager.podspec > OptimizelySDKDatafileManager.podspec.bak;
mv OptimizelySDKDatafileManager.podspec.bak OptimizelySDKDatafileManager.podspec;
# OptimizelySDKiOS.podspec
printf "OptimizelySDKiOS.podspec\n"
sed -e "s/s\.dependency \'OptimizelySDKDatafileManager\', \'.*\'/s\.dependency \'OptimizelySDKDatafileManager\', \'$OPTIMIZELY_SDK_DATAFILE_MANAGER_VERSION\'/g" OptimizelySDKiOS.podspec > OptimizelySDKiOS.podspec.bak;
mv OptimizelySDKiOS.podspec.bak OptimizelySDKiOS.podspec;
# OptimizelySDKTVOS.podspec
printf "OptimizelySDKTVOS.podspec\n\n"
sed -e "s/s\.dependency \'OptimizelySDKDatafileManager\', \'.*\'/s\.dependency \'OptimizelySDKDatafileManager\', \'$OPTIMIZELY_SDK_DATAFILE_MANAGER_VERSION\'/g" OptimizelySDKTVOS.podspec > OptimizelySDKTVOS.podspec.bak;
mv OptimizelySDKTVOS.podspec.bak OptimizelySDKTVOS.podspec;

# Update the OPTIMIZELY_SDK_USER_PROFILE_VERSION:
# OptimizelySDKUserProfile.podspec
printf "Updating OptimizelySDKUserProfile to $OPTIMIZELY_SDK_USER_PROFILE_VERSION in...\n"
printf "OptimizelySDKUserProfile.podspec\n"
sed -e "s/s\.version[ ]*=[ ]*\".*\"/s.version                 = \"$OPTIMIZELY_SDK_USER_PROFILE_VERSION\"/g" OptimizelySDKUserProfile.podspec > OptimizelySDKUserProfile.podspec.bak;
mv OptimizelySDKUserProfile.podspec.bak OptimizelySDKUserProfile.podspec;
# OptimizelySDKiOS.podspec
printf "OptimizelySDKTVOS.podspec\n"
sed -e "s/s\.dependency \'OptimizelySDKUserProfile\', \'.*\'/s\.dependency \'OptimizelySDKUserProfile\', \'$OPTIMIZELY_SDK_USER_PROFILE_VERSION\'/g" OptimizelySDKiOS.podspec > OptimizelySDKiOS.podspec.bak;
mv OptimizelySDKiOS.podspec.bak OptimizelySDKiOS.podspec;
# OptimizelySDKTVOS.podspec
printf "OptimizelySDKTVOS.podspec\n\n"
sed -e "s/s\.dependency \'OptimizelySDKUserProfile\', \'.*\'/s\.dependency \'OptimizelySDKUserProfile\', \'$OPTIMIZELY_SDK_USER_PROFILE_VERSION\'/g" OptimizelySDKTVOS.podspec > OptimizelySDKTVOS.podspec.bak;
mv OptimizelySDKTVOS.podspec.bak OptimizelySDKTVOS.podspec;

# make sure that all the podspec files are as expected!
open -a xcode *podspec;
read  -n 1 -p "Please visually inspect all podspec files...do all podspec files look correct? [y/n] $cr? " podspec_valid;
if [ "$podspec_valid" != "y" ]; then
    printf "\nCorrect the podspec files before proceeding!!\n"
    exit 1
fi;

# ---- commit podspec changes ----
printf "\n"
read  -n 1 -p "5. Commit and push version bump changes to devel? Skip this step if it has already been done. [y/n] $cr? " podspec_valid;
if [ "$podspec_valid" == "y" ]; then
    printf "\nCommitting and pushing devel with version bump changes...\n";
    git add -u
    git commit -m "Bumped version for new release."
    git push origin devel
fi;


# ---- merge devel to master ----
printf "\n6. Merge devel onto master:\n\ta. Create a pull request in github to merge devel onto master: https://github.com/optimizely/objective-c-sdk.\n\tb. Wait for Travis build to pass: https://travis-ci.org/optimizely/objective-c-sdk/pull_requests.\n\tc. Get an LGTM from someone on the team.\n\td. Merge the changes (don't squash!)\n";
read  -n 1 -p "Has master been merged with devel? [y/n] $cr? " podspec_valid;
if [ "$podspec_valid" != "y" ]; then
printf "\nPlease merge devel onto master before proceeding!!\n"
exit 1
fi;

# ---- git tag all modules----
printf "\n\n7. Tagging all modules...\n";
printf "Tagging core-$OPTIMIZELY_SDK_CORE_VERSION\n";
git tag -a core-$OPTIMIZELY_SDK_CORE_VERSION -m "Release $OPTIMIZELY_SDK_CORE_VERSION";
printf "Tagging shared-$OPTIMIZELY_SDK_SHARED_VERSION\n";
git tag -a shared-$OPTIMIZELY_SDK_SHARED_VERSION -m "Release $OPTIMIZELY_SDK_SHARED_VERSION";
printf "Tagging datafileManager-$OPTIMIZELY_SDK_DATAFILE_MANAGER_VERSION\n";
git tag -a datafileManager-$OPTIMIZELY_SDK_DATAFILE_MANAGER_VERSION -m "Release $OPTIMIZELY_SDK_DATAFILE_MANAGER_VERSION";
printf "Tagging eventDispatcher-$OPTIMIZELY_SDK_EVENT_DISPATCHER_VERSION\n";
git tag -a eventDispatcher-$OPTIMIZELY_SDK_EVENT_DISPATCHER_VERSION -m "Release $OPTIMIZELY_SDK_EVENT_DISPATCHER_VERSION";
printf "Tagging userProfile-$OPTIMIZELY_SDK_USER_PROFILE_VERSION\n";
git tag -a userProfile-$OPTIMIZELY_SDK_USER_PROFILE_VERSION -m "Release $OPTIMIZELY_SDK_USER_PROFILE_VERSION";
printf "Tagging iOS-$OPTIMIZELY_SDK_iOS_VERSION\n";
git tag -a iOS-$OPTIMIZELY_SDK_iOS_VERSION -m "Release $OPTIMIZELY_SDK_iOS_VERSION";
printf "Tagging tvOS-$OPTIMIZELY_SDK_TVOS_VERSION\n";
git tag -a tvOS-$OPTIMIZELY_SDK_TVOS_VERSION -m "Release $OPTIMIZELY_SDK_TVOS_VERSION"
printf "\nListing all tags...\n";
git for-each-ref --count=7 --sort=-taggerdate --format '%(refname)' refs/tags;
read  -n 1 -p "Are all tags valid? [y/n] $cr? " tagging_valid;
if [ "$tagging_valid" != "y" ]; then
    printf "\nCorrect the tag(s) before pushing tags!!\n"
    exit 1
fi;

## ---- git push tags ----
printf "\n\n8. Pushing all git tags...\n"
git push origin core-$OPTIMIZELY_SDK_CORE_VERSION --verbose;
printf "\n";
git push origin shared-$OPTIMIZELY_SDK_SHARED_VERSION --verbose;
printf "\n";
git push origin datafileManager-$OPTIMIZELY_SDK_DATAFILE_MANAGER_VERSION --verbose;
printf "\n";
git push origin eventDispatcher-$OPTIMIZELY_SDK_EVENT_DISPATCHER_VERSION --verbose;
printf "\n";
git push origin userProfile-$OPTIMIZELY_SDK_USER_PROFILE_VERSION --verbose;
printf "\n";
git push origin iOS-$OPTIMIZELY_SDK_iOS_VERSION --verbose;
printf "\n";
git push origin tvOS-$OPTIMIZELY_SDK_TVOS_VERSION --verbose;

# ---- Verify podspecs ----
printf "\n"
read  -n 1 -p "9. Verify all podspecs? Skip if this has already been done. [y/n] $cr? " verify_podspec;
if [ "$verify_podspec" == "y" ]; then
    printf "\nVerifying podspecs...\n";
    pods=(OptimizelySDKCore OptimizelySDKShared OptimizelySDKDatafileManager OptimizelySDKEventDispatcher OptimizelySDKUserProfile OptimizelySDKiOS OptimizelySDKTVOS);
    number_pods=${#pods[@]};

for (( i = 0; i < ${number_pods}; i++ ));
do
    echo "Verifying the ${pods[i]} pod"
    pod spec lint ${pods[i]}.podspec
done;
fi;

printf "\n"
read  -n 1 -p "Are all podspecs valid? (If none of the pods have been pushed to the Cocoapod trunk, you can ignore the dependency errors: None of your spec sources contain a spec satisfying the dependency.) [y/n] $cr? " podspec_valid;
if [ "$podspec_valid" != "y" ]; then
    printf "\nCorrect the podspec(s) before proceeding. Delete tag and retag the fixed podspec.\n"
    exit 1
fi;

# ---- Make sure you have a Cocoapod session running ----
printf "\n\n10. Verify Cocoapod trunk session...\n";
pod trunk me;

read  -n 1 -p "Do you have a valid Cocoapod session running? [y/n] $cr? " cocoapod_session;
if [ "$cocoapod_session" != "y" ]; then
printf "\nCreate a Cocoapod trunk session: https://guides.cocoapods.org/making/getting-setup-with-trunk.html.\n"
exit 1
fi;

# ---- push podspecs to cocoapods ----
# the podspecs need to be pushed in the correct order because of dependencies!
printf "\n\n11. Pushing podspecs to Cocoapods...\n";
for (( i = 0; i < ${number_pods}; i++ ));
do
    echo "Pushing the ${pods[i]} pod to Cocoapods"
    pod trunk push ${pods[i]}.podspec
done)
