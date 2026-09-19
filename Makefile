# Product
APP = Liceu
SCHEME = $(APP)
PROJECT = $(SCHEME).xcodeproj
BUNDLE_ID = com.thigcampos.Liceu

# Development
BUILD_DIR = .build
DESTINATION ?= MicroMac
DEBUG_APP_PATH = $(BUILD_DIR)/Build/Products/Debug-iphoneos/$(APP).app

# Logging
SILENT_XCBEAUTIFY = xcbeautify --disable-logging

clean:
	@echo Cleaning...
	@xcodebuild clean \
		-project $(PROJECT) \
		| $(SILENT_XCBEAUTIFY)
	@rm -rf $(BUILD_DIR)

build: clean
	@echo Building...
	@xcodebuild build \
    -project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination name=$(DESTINATION) \
    -derivedDataPath $(BUILD_DIR) \
		| $(SILENT_XCBEAUTIFY)

install: build
	@echo Installing on device...
	@xcrun devicectl device install app \
    --device $(DESTINATION) \
    $(DEBUG_APP_PATH)

run: install
	@echo Launching on device...
	@xcrun devicectl device process launch \
    --device $(DESTINATION) \
    $(BUNDLE_ID)

.PHONY: clean build install run
