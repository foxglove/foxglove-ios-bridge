.PHONY: build
build:
	# https://developer.apple.com/documentation/xcode/building-swift-packages-or-apps-that-use-them-in-continuous-integration-workflows
	# https://stackoverflow.com/questions/4969932/separate-build-directory-using-xcodebuild
	# https://forums.swift.org/t/swiftpm-with-git-lfs/42396/4
	GIT_LFS_SKIP_DOWNLOAD_ERRORS=1 \
	xcodebuild \
		-disableAutomaticPackageResolution \
		-clonedSourcePackagesDirPath .swiftpm-packages \
		-destination generic/platform=iOS \
		-scheme "Foxglove Bridge" \
		SYMROOT="$(PWD)"/build \
		-configuration Release \
		clean build analyze

.PHONY: lint-ci
lint-ci:
	docker run -t --platform linux/amd64 --rm -v "$(PWD)":/work -w /work ghcr.io/realm/swiftlint:0.53.0

.PHONY: format-ci
format-ci:
	docker run -t --rm -v "$(PWD)":/work ghcr.io/nicklockwood/swiftformat:0.52.8 --lint /work
