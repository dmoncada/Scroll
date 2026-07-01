SWIFT := "/usr/bin/swift"

CONFIGURATION ?= Debug

check:
	@$(SWIFT) format \
		lint \
		--strict \
		--parallel \
		--recursive \
		.

format:
	@$(SWIFT) format \
		--ignore-unparsable-files \
		--in-place \
		--parallel \
		--recursive \
		.

build:
	@echo "Building Scroll ($(CONFIGURATION))..."
	@xcodebuild build \
		CODE_SIGNING_ALLOWED='No' \
		-project Scroll.xcodeproj \
		-scheme Scroll \
		-configuration $(CONFIGURATION) \
		-destination 'generic/platform=macOS' \
		| xcbeautify

debug: CONFIGURATION = Debug
debug: build

release: CONFIGURATION = Release
release: build

.PHONY: check format build debug release
