imports = \
	@testable import ValidatedTests;

bootstrap: carthage xcodeproj

carthage:
	carthage update --use-submodules

xcodeproj:
	xcodegen

linux-main:
	sourcery \
		--sources ./Tests/ \
		--templates ./.sourcery-templates/ \
		--output ./Tests/ \
		--args testimports='$(imports)' \
		&& mv ./Tests/LinuxMain.generated.swift ./Tests/LinuxMain.swift

test-linux: linux-main
	docker build --tag tagged-testing . \
		&& docker run --rm tagged-testing

test-macos:
	set -o pipefail && \
	xcodebuild test \
		-scheme Validated-Package \
		-destination platform="macOS" \
		| xcpretty

test-ios:
	set -o pipefail && \
	xcodebuild test \
		-scheme Validated-Package \
		-destination platform="iOS Simulator,name=iPhone 8,OS=11.4" \
		| xcpretty

test-swift:
	swift test

test-all: test-linux test-mac test-ios
