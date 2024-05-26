#!/usr/bin/env bash

APP=Helium.app

# builds Helium using $BUILD_CMD, and uses xcpretty if it is installed
build() {
	ARCH=${1:x86_64}
	BUILD_CMD="xcodebuild
    -project Helium.xcodeproj
    -scheme Helium
    -configuration Release
    -archivePath Helium.xcarchive
    -destination platform=macOS,arch=${ARCH}
    archive"
	if command -v xcpretty >/dev/null; then
		set -o pipefail
		$BUILD_CMD | xcpretty --color | sed s/Copying.*/Copying.../g
	else
		$BUILD_CMD
	fi
}

# builds Helium and installs it to /Applications/$APP
install() {
	rm -rf /Applications/$APP
	build arm64
	cp -a Helium.xcarchive/Products/Applications/$APP /Applications/$APP
}

HELP_TEXT="
Please supply an argument for the build script:
  --build     build Helium
  --install   build and install Helium to /Applications/Helium.app
"

case $1 in
--build)
	build $2
	;;
--install)
	install
	;;
*) echo "$HELP_TEXT" ;;
esac
