#!/usr/bin/env bash

APP=Helium.app
BUILD_CMD='xcodebuild
  -project Helium.xcodeproj
  -scheme Helium
  -configuration Release
  -archivePath Helium.xcarchive
  archive'

# builds Helium using $BUILD_CMD, and uses xcpretty if it is installed
build() {
  if command -v xcpretty >/dev/null; then
    $BUILD_CMD | xcpretty --color | sed s/Copying.*/Copying.../g
  else
    $BUILD_CMD
  fi
}

# builds Helium and installs it to /Applications/$APP
install() {
  rm -rf /Applications/$APP
  build
  cp -a Helium.xcarchive/Products/Applications/$APP /Applications/$APP
}

HELP_TEXT="
Please supply an argument for the build script:
  --build     build Helium
  --install   build and install Helium to /Applications/Helium.app
"

case $1 in
--build)
  build
  ;;
--install)
  install
  ;;
*) echo "$HELP_TEXT" ;;
esac
