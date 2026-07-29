SWIFT := "/usr/bin/swift"

CONFIGURATION ?= Debug

.PHONY: check
check:
	@$(SWIFT) format \
		lint \
		--strict \
		--parallel \
		--recursive \
		.

.PHONY: format
format:
	@$(SWIFT) format \
		--ignore-unparsable-files \
		--in-place \
		--parallel \
		--recursive \
		.

.PHONY: build
build:
	@echo "Building Scroll ($(CONFIGURATION))..."
	@xcodebuild build \
		CODE_SIGNING_ALLOWED='No' \
		-project Scroll.xcodeproj \
		-scheme Scroll \
		-configuration $(CONFIGURATION) \
		-destination 'generic/platform=macOS' \
		| xcbeautify

.PHONY: debug
debug: CONFIGURATION = Debug
debug: build

.PHONY: release
release: CONFIGURATION = Release
release: build
