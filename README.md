<p align="center">
  <img src="Resources/icon_1024.png" alt="DispTog Icon" width="128" height="128">
</p>

# DispTog 🖥️

A menu bar app for macOS that toggles display **mirroring/extended** mode with one click.

[![Build](https://github.com/your-username/disptog/actions/workflows/build.yml/badge.svg)](https://github.com/your-username/disptog/actions/workflows/build.yml)
![macOS](https://img.shields.io/badge/macOS-11.0+-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange)

## ✨ Features

- 🖱️ **One-click toggle** from the menu bar to switch display modes
- ⌨️ **Global shortcut** (`⌘⇧M`) to toggle from anywhere
- 🪶 **Lightweight & simple** - minimal functionality only
- 🚫 **Hidden from Dock** - resides only in the menu bar

## 📦 Installation

### Method 1: Download DMG (Recommended)

1. Download the latest DMG from [Releases](https://github.com/your-username/disptog/releases/latest)
2. Open the DMG and drag DispTog to the Applications folder
3. Launch DispTog

### Method 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/your-username/disptog.git
cd disptog

# Build
make build

# Install to /Applications
make install
```

### Method 3: Build with Xcode

1. Open Xcode
2. Select File > New > Project > macOS > App
3. Add Swift files from `Sources/` to the project
4. Merge contents of `Sources/Info.plist` into the project's Info.plist
5. Build & Run

## 🚀 Usage

### Launch

```bash
# Run after building
make run

# Or open the app directly
open /Applications/DispTog.app
```

### Controls

| Action | Description |
|--------|-------------|
| 🖱️ Click menu bar icon | Show menu |
| 🔄 Select "Toggle Mirroring/Extended" | Toggle mode |
| ⌨️ `⌘⇧M` (Command + Shift + M) | Toggle with global shortcut |

### Display Modes

- **🪞 Mirroring**: Show the same screen on all displays
- **📺 Extended Desktop**: Use each display as an independent screen

## ⚙️ Initial Setup

Accessibility permission is required to use the global shortcut:

1. Open **System Settings**
2. Go to **Privacy & Security** > **Accessibility**
3. Enable **DispTog**

## 🔧 Development

### Requirements

- macOS 11.0 (Big Sur) or later
- Xcode Command Line Tools
- [Mint](https://github.com/yonaskolb/Mint) (Swift tool manager)

```bash
# Install Command Line Tools
xcode-select --install

# Install Mint
brew install mint

# Setup development tools (SwiftLint, SwiftFormat)
make setup
```

### Build Commands

```bash
make build      # Build the app
make run        # Run the app
make debug      # Run from terminal with logs
make clean      # Remove build artifacts
make install    # Install to /Applications
make uninstall  # Uninstall the app
make lint       # Run SwiftLint
make lint-fix   # Auto-fix with SwiftLint
make format     # Format with SwiftFormat
make dmg        # Create DMG file
```

### Project Structure

```
disptog/
├── README.md              # This file
├── LICENSE                # MIT License
├── CONTRIBUTING.md        # Contribution guide
├── Makefile               # Build script
├── .swiftlint.yml         # SwiftLint configuration
├── .swiftformat           # SwiftFormat configuration
├── Mintfile               # Swift tool version management
├── .github/
│   └── workflows/
│       ├── build.yml      # CI: Build & Lint
│       └── release.yml    # CD: Release & DMG creation
├── Sources/
│   ├── DispTogApp.swift      # Main app (entry point)
│   ├── DisplayManager.swift  # Display control logic
│   └── Info.plist            # App configuration
├── scripts/
│   └── create-dmg.sh      # DMG creation script
└── build/                 # Build artifacts (.gitignore)
    └── DispTog.app
```

### Code Explanation

Detailed comments are provided in Swift code for TypeScript/JavaScript developers.

#### `DispTogApp.swift`
- **Role**: Application entry point
- **Equivalent concept**: `index.ts` / `main.ts`
- **Main responsibilities**: 
  - Create menu bar item
  - Register global shortcut
  - Handle UI events

#### `DisplayManager.swift`
- **Role**: Business logic for display control
- **Equivalent concept**: Service class / Utility module
- **Main responsibilities**:
  - Get display information
  - Toggle mirroring/extended mode

### How to Release

To release a new version:

```bash
# Create and push a tag
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions will automatically create a DMG and publish the Release.

## 🐛 Troubleshooting

### Shortcut not working

1. Check if permission is granted in System Settings > Privacy & Security > Accessibility
2. Restart the app

### Display not switching

1. Verify that 2 or more displays are connected
2. Check logs with `make debug`

### Build errors

```bash
# Reinstall Xcode Command Line Tools
sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install
```

## 🤝 Contributing

Issues and Pull Requests are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- [Apple CoreGraphics Framework](https://developer.apple.com/documentation/coregraphics)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [SwiftLint](https://github.com/realm/SwiftLint)
