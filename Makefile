# DispTog - Makefile
# Build script for macOS display toggle app
#
# Usage:
#   make build   - Build the app
#   make install - Install app to /Applications
#   make run     - Run the app
#   make clean   - Remove build artifacts
#   make lint    - Run SwiftLint
#   make format  - Format with SwiftFormat
#   make dmg     - Create DMG file

# Configuration
APP_NAME = DispTog
VERSION ?= 1.0.0
BUILD_DIR = build
APP_BUNDLE = $(BUILD_DIR)/$(APP_NAME).app
CONTENTS_DIR = $(APP_BUNDLE)/Contents
MACOS_DIR = $(CONTENTS_DIR)/MacOS
RESOURCES_DIR = $(CONTENTS_DIR)/Resources

# Source files
SOURCES = Sources/DispTogApp.swift Sources/DisplayManager.swift

# Compiler settings
SWIFTC = swiftc
SWIFT_FLAGS = -O -target arm64-apple-macos11.0 -target x86_64-apple-macos11.0

# Default target
.PHONY: all
all: build

# Build
.PHONY: build
build: $(APP_BUNDLE)
	@echo "✅ Build complete: $(APP_BUNDLE)"

# Create application bundle
$(APP_BUNDLE): $(SOURCES) Sources/Info.plist
	@echo "🔨 Building..."
	@mkdir -p $(MACOS_DIR)
	@mkdir -p $(RESOURCES_DIR)
	
	# Compile Swift sources
	@echo "  📦 Compiling..."
	@$(SWIFTC) -o $(MACOS_DIR)/$(APP_NAME) \
		-framework Cocoa \
		-framework CoreGraphics \
		-framework Carbon \
		$(SOURCES)
	
	# Copy Info.plist
	@cp Sources/Info.plist $(CONTENTS_DIR)/Info.plist
	
	# Copy icon (if exists)
	@if [ -f Resources/AppIcon.icns ]; then \
		cp Resources/AppIcon.icns $(RESOURCES_DIR)/AppIcon.icns; \
		echo "  🎨 Icon copied"; \
	fi
	
	# Create PkgInfo
	@echo "APPL????" > $(CONTENTS_DIR)/PkgInfo

# Install (copy to /Applications)
.PHONY: install
install: build
	@echo "📥 Installing to /Applications..."
	@rm -rf /Applications/$(APP_NAME).app
	@cp -R $(APP_BUNDLE) /Applications/
	@echo "✅ Installation complete: /Applications/$(APP_NAME).app"
	@echo ""
	@echo "⚠️  Note for first launch:"
	@echo "   Go to System Settings > Privacy & Security > Accessibility"
	@echo "   and enable DispTog (required for global shortcut)"

# Run
.PHONY: run
run: build
	@echo "🚀 Launching $(APP_NAME)..."
	@open $(APP_BUNDLE)

# Cleanup
.PHONY: clean
clean:
	@echo "🧹 Cleaning up..."
	@rm -rf $(BUILD_DIR)
	@echo "✅ Cleanup complete"

# Uninstall
.PHONY: uninstall
uninstall:
	@echo "🗑️  Uninstalling..."
	@rm -rf /Applications/$(APP_NAME).app
	@echo "✅ Uninstall complete"

# Development: Run with logs
.PHONY: debug
debug: build
	@echo "🔍 Launching in debug mode..."
	@$(MACOS_DIR)/$(APP_NAME)

# Mint is required
# Install: brew install mint

# Check Mint existence
define check_mint
	@if ! command -v mint >/dev/null 2>&1; then \
		echo "❌ Mint is not installed"; \
		echo ""; \
		echo "Installation:"; \
		echo "  brew install mint"; \
		echo ""; \
		echo "Then setup tools:"; \
		echo "  make setup"; \
		exit 1; \
	fi
endef

# Lint (SwiftLint)
.PHONY: lint
lint:
	$(call check_mint)
	@echo "🔍 Running SwiftLint..."
	@mint run swiftlint

# Lint (auto-fix)
.PHONY: lint-fix
lint-fix:
	$(call check_mint)
	@echo "🔧 Auto-fixing with SwiftLint..."
	@mint run swiftlint -- --fix

# Format (SwiftFormat)
.PHONY: format
format:
	$(call check_mint)
	@echo "✨ Formatting with SwiftFormat..."
	@mint run swiftformat .

# Format check (for CI)
.PHONY: format-check
format-check:
	$(call check_mint)
	@echo "🔍 Checking format..."
	@mint run swiftformat -- --lint . || (echo "❌ Formatting required: make format" && exit 1)

# Tool setup (from Mintfile)
.PHONY: setup
setup:
	$(call check_mint)
	@echo "🔧 Setting up development tools..."
	@mint bootstrap
	@echo "✅ Setup complete"

# Create DMG
.PHONY: dmg
dmg: build
	@chmod +x scripts/create-dmg.sh
	@./scripts/create-dmg.sh $(VERSION)

# Help
.PHONY: help
help:
	@echo "DispTog - macOS Display Toggle App"
	@echo ""
	@echo "Available commands:"
	@echo "  make build     - Build the app"
	@echo "  make install   - Install to /Applications"
	@echo "  make run       - Run the app"
	@echo "  make debug     - Run from terminal with logs"
	@echo "  make clean     - Remove build artifacts"
	@echo "  make uninstall - Uninstall the app"
	@echo "  make lint      - Run SwiftLint"
	@echo "  make lint-fix  - Auto-fix with SwiftLint"
	@echo "  make format    - Format with SwiftFormat"
	@echo "  make setup     - Setup development tools"
	@echo "  make dmg       - Create DMG file (VERSION=x.x.x)"
	@echo "  make help      - Show this help"
