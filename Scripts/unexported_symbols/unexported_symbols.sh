#!/bin/bash
################################################################
#     unexported_symbols.sh
#
# Use like this:
#
# sh ./unexported_symbols.sh
#
# Outputs revised unexported_symbols.txt file to "${universal_dir}"
# directory home of OptimizelySDKUniversal.xcodeproj .  The 2
# universal *.framework target's "Build Settings" specify
# "Unexported Symbols File" == "unexported_symbols.txt" .  E.G.
#
# cd ~/objective-c-sdk-oasis-1303-nike/Scripts/unexported_symbols
# sh ./unexported_symbols.sh
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
  if [ "$(uname)" != "Darwin" ]; then
    echo "${0} MUST be run on a Mac."
    exit 1
  fi
  #local source_dir=`dirname $0`
  local source_dir="$(dirname $0)"
  local universal_dir="${source_dir}/../../OptimizelySDKUniversal"
  local universal_framework="${universal_dir}/generated-frameworks/Release-iOS-universal-SDK/OptimizelySDKiOS.framework"
  if [[ ! -d "${universal_framework}" ]]; then
    # Build "${universal_framework}" if it doesn't exist.
    echo "Building Universal Framework"
    xcodebuild -project "${universal_dir}/OptimizelySDKUniversal.xcodeproj" \
               -target "OptimizelySDKiOS-Universal" \
               -configuration "Release"
  fi
  local arm64_slice="${source_dir}/OptimizelySDKiOS-arm64"
  {
    tempfiles+=( "${arm64_slice}" )
    local universal_binary="${universal_framework}/OptimizelySDKiOS"
    lipo -extract arm64 "${universal_binary}" -output "${arm64_slice}"
  }
  local nm_txt="${arm64_slice}.txt"
  {
    tempfiles+=( "${nm_txt}" )
    nm -g "${arm64_slice}" > "${nm_txt}"
  }
  local awk_txt="${source_dir}/unexported_symbols.txt"
  {
    tempfiles+=( "${awk_txt}" )
    awk -f "${source_dir}/unexported_symbols.awk" "${nm_txt}" > "${awk_txt}"
  }
  {
    local unexported_symbols_txt="${universal_dir}/unexported_symbols.txt"
    mv "${awk_txt}" "${unexported_symbols_txt}"
    echo "SUCCESS creating unexported_symbols.txt"
  }
  cleanup
}

main
