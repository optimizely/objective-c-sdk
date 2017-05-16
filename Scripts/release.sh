#!/bin/bash

# This script guides you through all the steps needed to do a new release.
# The script assumes you are on the master branch and are in the Script folder.
# The script does the following:

# 0. If revised or additional third-party dependencies are added (aside from
# JSONModel, MurmurHash3, or FMDB), run the unexported_symbols.sh script to create
# a new unexported_symbols.txt, which hides all third-party dependency symbols.
# 1. Reminder prompt to update the CHANGELOG.
# 2. Reminder prompt to update the Build Settings with the proper version number for each module that requires a version bump.
# 3. Gets the version numbers from the XCode build settings.
# 4. Build the universal frameworks.
# 5. Update podspec files with the correct version number.
# 6. Verify podspec files.
# 7. Commit and push the version bump changes (e.g., the universal frameworks, podspec updates, and build setting updates) to master.
# 8. git tag all the modules.
# 9. git push all tags.
# 10. Confirm if pod trunk session is open.
# 11. pod trunk push all the podspecs.
# 12. If patch release, than cherry pick changes from master onto the release branch; otherwise, create the release branch.

# Change to the project root folder
(cd ..;
printf "Current working directory: $PWD.\n\n";

#1. Prompt a reminder to update the CHANGELOG
read  -n 1 -p "1. Have you updated the CHANGELOG? (Please check the contents and formatting.) [y/n] $cr " changelog_update;
if [ "$changelog_update" != "y" ]; then
    printf "\nUpdate the CHANGELOG before proceeding!!\n"
    exit 1
fi;

#2. Prompt a reminder to update Build Setting version number. Make sure this is done in the Build Settings at the Project level (not at the Target level) so that all Targets will inherit the version number.
printf "\n\n";
read  -n 1 -p "2. Have you updated the version number for all frameworks in the Xcode Build Settings? Make sure this is done at the Project level (not at the Target level) so that all Targets will inherit the version number. [y/n] $cr? " build_setting_update;
if [ "$build_setting_update" != "y" ]; then
    printf "\nUpdate the version numbers for all frameworks in the Xcode Build Settings before proceeding!!\n"
    exit 1
fi;

## ---- Extract version numbers from XCode build settings ----
printf "\n\n3. Getting new versions from XCode Build Settings...\n\n";

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

# OPTIMIZELY_SDK_USER_PROFILE_SERVICE_VERSION
OPTIMIZELY_SDK_USER_PROFILE_SERVICE_VERSION=$(xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKUserProfileServiceiOS -showBuildSettings | sed -n 's/OPTIMIZELY_SDK_USER_PROFILE_SERVICE_VERSION = \(.*\)/\1/p' | sed 's/ //g');
echo "OPTIMIZELY_SDK_USER_PROFILE_SERVICE_VERSION = $OPTIMIZELY_SDK_USER_PROFILE_SERVICE_VERSION";

# OPTIMIZELY_SDK_iOS_VERSION
OPTIMIZELY_SDK_iOS_VERSION=$(xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKiOS -showBuildSettings | sed -n 's/OPTIMIZELY_SDK_iOS_VERSION = \(.*\)/\1/p' | sed 's/ //g');
echo "OPTIMIZELY_SDK_iOS_VERSION = $OPTIMIZELY_SDK_iOS_VERSION";

# OPTIMIZELY_SDK_TVOS_VERSION
OPTIMIZELY_SDK_TVOS_VERSION=$(xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKTVOS -showBuildSettings | sed -n 's/OPTIMIZELY_SDK_TVOS_VERSION = \(.*\)/\1/p' | sed 's/ //g');
echo "OPTIMIZELY_SDK_TVOS_VERSION = $OPTIMIZELY_SDK_TVOS_VERSION";

# OPTIMIZELY_SDK_iOS_UNIVERSAL_VERSION
OPTIMIZELY_SDK_iOS_UNIVERSAL_VERSION=$(xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKiOSUniversal -showBuildSettings | sed -n 's/OPTIMIZELY_SDK_iOS_UNIVERSAL_VERSION = \(.*\)/\1/p' | sed 's/ //g');
echo "OPTIMIZELY_SDK_iOS_UNIVERSAL_VERSION = $OPTIMIZELY_SDK_iOS_UNIVERSAL_VERSION";

# OPTIMIZELY_SDK_TVOS_UNIVERSAL_VERSION
OPTIMIZELY_SDK_TVOS_UNIVERSAL_VERSION=$(xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKTVOSUniversal -showBuildSettings | sed -n 's/OPTIMIZELY_SDK_TVOS_UNIVERSAL_VERSION = \(.*\)/\1/p' | sed 's/ //g');
echo "OPTIMIZELY_SDK_TVOS_UNIVERSAL_VERSION = $OPTIMIZELY_SDK_TVOS_UNIVERSAL_VERSION";

# make sure that all the version numbers are as expected!
printf "\n"
read  -n 1 -p "Do all the version numbers look correct? [y/n] $cr? " versions_valid;
if [ "$versions_valid" != "y" ]; then
    printf "\nCorrect the version numbers in the Xcode Build Settings before proceeding!!\n"
    exit 1
fi;

# ---- Build the universal frameworks ----
printf "\n\n4. Building the universal frameworks...\n\n"
xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKiOS-Universal -configuration Release
xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKTVOS-Universal -configuration Release

# ---- Update podspec files ----
printf "\n\n5. Updating podspec files with the new version numbers...\n\n"
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
# OptimizelySDKUserProfileService.podspec
printf "OptimizelySDKUserProfileService.podspec\n\n"
sed -e "s/s\.dependency \'OptimizelySDKShared\', \'.*\'/s\.dependency \'OptimizelySDKShared\', \'$OPTIMIZELY_SDK_SHARED_VERSION\'/g" OptimizelySDKUserProfileService.podspec > OptimizelySDKUserProfileService.podspec.bak;
mv OptimizelySDKUserProfileService.podspec.bak OptimizelySDKUserProfileService.podspec;

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

# Update the OPTIMIZELY_SDK_USER_PROFILE_SERVICE_VERSION:
# OptimizelySDKUserProfileService.podspec
printf "Updating OptimizelySDKUserProfileService to $OPTIMIZELY_SDK_USER_PROFILE_SERVICE_VERSION in...\n"
printf "OptimizelySDKUserProfileService.podspec\n"
sed -e "s/s\.version[ ]*=[ ]*\".*\"/s.version                 = \"$OPTIMIZELY_SDK_USER_PROFILE_SERVICE_VERSION\"/g" OptimizelySDKUserProfileService.podspec > OptimizelySDKUserProfileService.podspec.bak;
mv OptimizelySDKUserProfileService.podspec.bak OptimizelySDKUserProfileService.podspec;
# OptimizelySDKiOS.podspec
printf "OptimizelySDKTVOS.podspec\n"
sed -e "s/s\.dependency \'OptimizelySDKUserProfileService\', \'.*\'/s\.dependency \'OptimizelySDKUserProfileService\', \'$OPTIMIZELY_SDK_USER_PROFILE_SERVICE_VERSION\'/g" OptimizelySDKiOS.podspec > OptimizelySDKiOS.podspec.bak;
mv OptimizelySDKiOS.podspec.bak OptimizelySDKiOS.podspec;
# OptimizelySDKTVOS.podspec
printf "OptimizelySDKTVOS.podspec\n\n"
sed -e "s/s\.dependency \'OptimizelySDKUserProfileService\', \'.*\'/s\.dependency \'OptimizelySDKUserProfileService\', \'$OPTIMIZELY_SDK_USER_PROFILE_SERVICE_VERSION\'/g" OptimizelySDKTVOS.podspec > OptimizelySDKTVOS.podspec.bak;
mv OptimizelySDKTVOS.podspec.bak OptimizelySDKTVOS.podspec;

# make sure that all the podspec files are as expected!
open -a xcode *podspec;
read  -n 1 -p "Please visually inspect all podspec files...do all podspec files look correct? [y/n] $cr? " podspec_valid;
if [ "$podspec_valid" != "y" ]; then
    printf "\nCorrect the podspec files before proceeding!!\n"
    exit 1
fi;

# ---- Verify podspecs ----
printf "\n\n"
read  -n 1 -p "6. Verify all podspecs? Skip if this has already been done. [y/n] $cr? " verify_podspec;
if [ "$verify_podspec" == "y" ]; then
printf "\nVerifying podspecs...\n";
pods=(OptimizelySDKCore OptimizelySDKShared OptimizelySDKDatafileManager OptimizelySDKEventDispatcher OptimizelySDKUserProfileService OptimizelySDKiOS OptimizelySDKTVOS);
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

# ---- commit podspec changes ----
printf "\n"
read  -n 1 -p "7. Commit and push version bump changes to master? Skip this step if it has already been done. [y/n] $cr? " podspec_valid;
if [ "$podspec_valid" == "y" ]; then
    printf "\nCommitting and pushing master with version bump changes...\n";
    git add -u
    git commit -m "Bumped version for new release."
    git push origin devel
fi;

# ---- git tag all modules----
printf "\n\n8. Tagging all modules...\n";
printf "Tagging core-$OPTIMIZELY_SDK_CORE_VERSION\n";
git tag -a core-$OPTIMIZELY_SDK_CORE_VERSION -m "Release $OPTIMIZELY_SDK_CORE_VERSION";
printf "Tagging shared-$OPTIMIZELY_SDK_SHARED_VERSION\n";
git tag -a shared-$OPTIMIZELY_SDK_SHARED_VERSION -m "Release $OPTIMIZELY_SDK_SHARED_VERSION";
printf "Tagging datafileManager-$OPTIMIZELY_SDK_DATAFILE_MANAGER_VERSION\n";
git tag -a datafileManager-$OPTIMIZELY_SDK_DATAFILE_MANAGER_VERSION -m "Release $OPTIMIZELY_SDK_DATAFILE_MANAGER_VERSION";
printf "Tagging eventDispatcher-$OPTIMIZELY_SDK_EVENT_DISPATCHER_VERSION\n";
git tag -a eventDispatcher-$OPTIMIZELY_SDK_EVENT_DISPATCHER_VERSION -m "Release $OPTIMIZELY_SDK_EVENT_DISPATCHER_VERSION";
printf "Tagging UserProfileService-$OPTIMIZELY_SDK_USER_PROFILE_SERVICE_VERSION\n";
git tag -a UserProfileService-$OPTIMIZELY_SDK_USER_PROFILE_SERVICE_VERSION -m "Release $OPTIMIZELY_SDK_USER_PROFILE_SERVICE_VERSION";
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
printf "\n\n9. Pushing all git tags...\n"
git push origin core-$OPTIMIZELY_SDK_CORE_VERSION --verbose;
printf "\n";
git push origin shared-$OPTIMIZELY_SDK_SHARED_VERSION --verbose;
printf "\n";
git push origin datafileManager-$OPTIMIZELY_SDK_DATAFILE_MANAGER_VERSION --verbose;
printf "\n";
git push origin eventDispatcher-$OPTIMIZELY_SDK_EVENT_DISPATCHER_VERSION --verbose;
printf "\n";
git push origin UserProfileService-$OPTIMIZELY_SDK_USER_PROFILE_SERVICE_VERSION --verbose;
printf "\n";
git push origin iOS-$OPTIMIZELY_SDK_iOS_VERSION --verbose;
printf "\n";
git push origin tvOS-$OPTIMIZELY_SDK_TVOS_VERSION --verbose;

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


# ---- Prompt to determine what kind of release ----
# patch releases require cherry-picking changes onto the release branch
read  -n 1 -p "12. Is this a patch release? [y/n] $cr " patch_release;
if [ "$patch_release" == "y" ]; then
printf "\n\nMoving to the release branch $OPTIMIZELY_SDK_CORE_VERSION_MAJOR.$OPTIMIZELY_SDK_CORE_VERSION_MINOR.x.\n";
git checkout -b $OPTIMIZELY_SDK_CORE_VERSION_MAJOR.$OPTIMIZELY_SDK_CORE_VERSION_MINOR.x
printf "\n\nCherry-pick last commit from master.\n";
git cherry-pick master
exit 1
fi;
# if not a patch release, than a release branch needs to be created
printf "\n\nCreating the $OPTIMIZELY_SDK_CORE_VERSION_MAJOR.$OPTIMIZELY_SDK_CORE_VERSION_MINOR.x release branch...\n";
git checkout -b $OPTIMIZELY_SDK_CORE_VERSION_MAJOR.$OPTIMIZELY_SDK_CORE_VERSION_MINOR.x
git push
done)
