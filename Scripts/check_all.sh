#!/bin/bash
################################################################
# check_all.sh
#
# This script builds all the schemes, runs all tests, and
# checks to make sure there are no absolute paths
# in XCode project files.
################################################################
./Scripts/build_all.sh;
./Scripts/local_travis.sh;
grep -r "<absolute>" .;
