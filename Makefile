SIMULATOR = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Applications/iPhone\ Simulator.app/Contents/MacOS/iPhone\ Simulator
SDK = $(if $(IOS_SDK), $(IOS_SDK), iphonesimulator)
.DEFAULT_GOAL := help
PWD = $(shell pwd)
CONFIG = Release
EXTRA_PREPROCESSOR_DEFINITIONS =

PROJECT_NAME=OptimizelySDK
company=Optimizely
companyID=com.optimizely
companyURL=http://www.optimizely.com
DOC_OUTPUT_DIR=${PWD}/help
RETAIL_OUTPUT_DIR=${PWD}/Optimizely-Core-Objective-C-SDK
FRAMEWORK_PATH=${PWD}/OptimizelySDK/build/Release-iphoneos/OptimizelySDK.framework
BUILD_ERROR_MSG=$(shell perl -MURI::Escape -e 'print uri_escape($$ARGV[0]);' "${BUILD_NUMBER}-${GIT_BRANCH} failed to build! Look at ${BUILD_URL}")

###############################################
# Build commands
###############################################
seperator:
	@echo "############################################################################"

build-docs: seperator
	@echo "Building Documentation in ${DOC_OUTPUT_DIR}"
	rm -rf ${DOC_OUTPUT_DIR}
	mkdir -p ${DOC_OUTPUT_DIR}
	appledoc \
		--project-name "${PROJECT_NAME}" \
		--project-company "${company}" \
		--company-id "${companyID}" \
		--docset-atom-filename "${company}.atom" \
		--docset-feed-url "${companyURL}/${company}/%DOCSETATOMFILENAME" \
		--docset-package-url "${companyURL}/${company}/%DOCSETPACKAGEFILENAME" \
		--docset-fallback-url "${companyURL}/${company}" \
		--output "${DOC_OUTPUT_DIR}" \
		--publish-docset \
		--logformat xcode \
		--keep-intermediate-files \
		--no-repeat-first-par \
		--no-warn-invalid-crossref \
		--exit-threshold 2 \
		"${PWD}/OptimizelySDK/OptimizelySDK"

###############################################
# Debug/Info commands
###############################################
info: info-sdks info-project-OptimizelySDK info-project-iOSDemo
info-project-%:
	xcodebuild -list -project ./$*/$*.xcodeproj/
info-sdks:
	xcodebuild -showsdks
clean:
	@rm -rf OptimizelySDK/build/
	@rm -rf ${RETAIL_OUTPUT_DIR}
	@rm -rf ./OptimizelyRetail-SDK.zip
	@rm -rf ./help
	@git clean -fX
help:
		@echo ""
		@echo "make build-docs        - builds documentation "
		@echo "make info              - dumps info about Optimizely's projects and xcodec"
		@echo "make clean             - clean out the current directory"
		@echo ""
