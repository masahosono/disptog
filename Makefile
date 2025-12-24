# DispTog Makefile

APP_NAME = DispTog
VERSION ?= 1.0.0
BUILD_DIR = build
APP_BUNDLE = $(BUILD_DIR)/$(APP_NAME).app
CONTENTS_DIR = $(APP_BUNDLE)/Contents
MACOS_DIR = $(CONTENTS_DIR)/MacOS
RESOURCES_DIR = $(CONTENTS_DIR)/Resources
SOURCES = Sources/DispTogApp.swift Sources/DisplayManager.swift

.PHONY: all build install run clean uninstall debug lint lint-fix format format-check setup dmg help

all: build

build: $(APP_BUNDLE)
	@echo "✅ Build complete: $(APP_BUNDLE)"

$(APP_BUNDLE): $(SOURCES) Sources/Info.plist
	@mkdir -p $(MACOS_DIR) $(RESOURCES_DIR)
	@swiftc -o $(MACOS_DIR)/$(APP_NAME) \
		-framework Cocoa \
		-framework CoreGraphics \
		-framework Carbon \
		$(SOURCES)
	@cp Sources/Info.plist $(CONTENTS_DIR)/Info.plist
	@if [ -f Resources/AppIcon.icns ]; then cp Resources/AppIcon.icns $(RESOURCES_DIR)/; fi
	@echo "APPL????" > $(CONTENTS_DIR)/PkgInfo

install: build
	@rm -rf /Applications/$(APP_NAME).app
	@cp -R $(APP_BUNDLE) /Applications/
	@echo "✅ Installed to /Applications/$(APP_NAME).app"

run: build
	@open $(APP_BUNDLE)

clean:
	@rm -rf $(BUILD_DIR)
	@echo "✅ Clean complete"

uninstall:
	@rm -rf /Applications/$(APP_NAME).app
	@echo "✅ Uninstalled"

debug: build
	@$(MACOS_DIR)/$(APP_NAME)

define check_mint
	@command -v mint >/dev/null 2>&1 || { echo "❌ Mint not installed. Run: brew install mint"; exit 1; }
endef

lint:
	$(call check_mint)
	@mint run swiftlint

lint-fix:
	$(call check_mint)
	@mint run swiftlint -- --fix

format:
	$(call check_mint)
	@mint run swiftformat .

format-check:
	$(call check_mint)
	@mint run swiftformat -- --lint .

setup:
	$(call check_mint)
	@mint bootstrap

dmg: build
	@chmod +x scripts/create-dmg.sh
	@./scripts/create-dmg.sh $(VERSION)

help:
	@echo "make build     - Build the app"
	@echo "make install   - Install to /Applications"
	@echo "make run       - Run the app"
	@echo "make debug     - Run with terminal output"
	@echo "make clean     - Remove build artifacts"
	@echo "make uninstall - Uninstall the app"
	@echo "make lint      - Run SwiftLint"
	@echo "make format    - Format with SwiftFormat"
	@echo "make dmg       - Create DMG (VERSION=x.x.x)"
