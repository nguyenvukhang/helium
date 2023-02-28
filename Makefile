MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR  := $(dir $(MAKEFILE_PATH))

fmt:
	clang-format -i 'Wacom Kit'/*.m 'Wacom Kit'/*.h

build: FORCE
	rm -rf DerivedData
	xcodebuild -project 'Wacom Kit.xcodeproj' -scheme 'Wacom Kit' \
		clean archive -configuration Release \
		-archivePath 'Wacom Kit.xcarchive'

install:
	rm -rf '/Applications/Wacom Kit.app'
	make build
	cp -r 'Wacom Kit.xcarchive/Products/Applications/Wacom Kit.app' \
		'/Applications/Wacom Kit.app'

open:
	open 'Wacom Kit.xcodeproj'

FORCE: ;
