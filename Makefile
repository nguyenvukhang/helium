MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR  := $(dir $(MAKEFILE_PATH))

BUILD_CMD:= xcodebuild -project 'Wacom Kit.xcodeproj' -scheme 'Wacom Kit' \
		clean archive -configuration Release \
		-archivePath 'Wacom Kit.xcarchive'

fmt:
	clang-format -i 'Wacom Kit'/*.m 'Wacom Kit'/*.h

build: FORCE
	rm -rf DerivedData
	$(BUILD_CMD)

install:
	make build
	rm -rf '/Applications/Wacom Kit.app'
	cp -a 'Wacom Kit.xcarchive/Products/Applications/Wacom Kit.app' \
		'/Applications/Wacom Kit.app'

lsp:
	$(BUILD_CMD) | xcpretty -r json-compilation-database --output compile_commands.json

open:
	open 'Wacom Kit.xcodeproj'

FORCE: ;
