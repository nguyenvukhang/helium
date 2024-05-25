MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR  := $(dir $(MAKEFILE_PATH))

BUILD:=bash $(MAKEFILE_DIR)/scripts/build.sh
APP:=Helium.app

fmt:
	swiftformat **/*.swift

build-arm64:
	$(BUILD) --build arm64

build-x86_64:
	$(BUILD) --build x86_64

install:
	$(BUILD) --install

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
