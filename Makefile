MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR  := $(dir $(MAKEFILE_PATH))

BUILD_CMD:= xcodebuild -project Helium.xcodeproj -scheme Helium \
		clean archive -configuration Release \
		-archivePath Helium.xcarchive
APP:=Helium.app

fmt:
	swiftformat **/*.swift

build: FORCE
	$(BUILD_CMD)

install:
	rm -rf /Applications/$(APP)
	make build
	cp -a Helium.xcarchive/Products/Applications/$(APP) /Applications/$(APP)

dev:
	open Helium.xcodeproj

open:
	open /Applications/$(APP)

quit:
	osascript -e 'quit app "$(APP)"'

all:
	@make quit
	@make install
	@make open

size:
	du -sh /Applications/$(APP)

FORCE: ;
