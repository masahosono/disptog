# Contributing Guide

Thank you for considering contributing to DispTog! 🎉

## Development Environment Setup

### Requirements

- macOS 11.0 (Big Sur) or later
- Xcode Command Line Tools
- [Homebrew](https://brew.sh/) (Package manager)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (Project generation)

### Build

```bash
# 1. Fork this repository on GitHub
#    https://github.com/masahosono/disptog

# 2. Clone your fork
git clone https://github.com/<your-username>/disptog.git
cd disptog

# 3. Add upstream remote
git remote add upstream https://github.com/masahosono/disptog.git

# 4. Install Command Line Tools (if not yet installed)
xcode-select --install

# 5. Install XcodeGen
brew install xcodegen

# 6. Generate Xcode project
xcodegen generate

# 7. Resolve SPM dependencies (for SwiftLint, SwiftFormat)
swift package resolve

# 8. Build
xcodebuild -project DispTog.xcodeproj -scheme DispTog -configuration Debug -derivedDataPath build

# 9. Run (open the built app)
open build/Build/Products/Debug/DispTog.app

# Or build and run in Xcode
open DispTog.xcodeproj
# Press ⌘B to build, ⌘R to run
```

## Coding Style

### SwiftLint & SwiftFormat

This project uses SwiftLint (linter) and SwiftFormat (formatter).
Please ensure there are no errors before submitting a pull request.

```bash
# Format (auto-format like Prettier)
swift run swiftformat .

# Check formatting
swift run swiftformat --lint .

# Run lint
swift run swiftlint
```

CI runs `swift run swiftformat --lint .` and `swift run swiftlint --strict`.

### Comments

- Write code comments in English
- Try to write explanations that are easy to understand for TypeScript/JavaScript developers
- For complex logic, explain "why" it's done that way

## Pull Request Process

1. Sync your fork with upstream
   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```
2. Create a feature branch
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. Commit your changes
   ```bash
   git commit -m 'Add amazing feature'
   ```
4. Push to your fork
   ```bash
   git push origin feature/amazing-feature
   ```
5. Create a Pull Request from your fork to the upstream repository

### Commit Messages

We recommend the following format:

- `feat: Add new feature`
- `fix: Fix bug`
- `docs: Update documentation`
- `refactor: Refactor code`
- `style: Fix code style`
- `test: Add or fix tests`
- `chore: Build or tool-related changes`

## Issues

### Bug Reports

When reporting a bug, please include the following information:

- macOS version
- Number and type of connected displays
- Steps to reproduce
- Expected behavior
- Actual behavior

### Feature Requests

Feature requests are very welcome! However, since this app prioritizes "simplicity," feature additions will be carefully considered.

## Questions

If you have questions, please create an Issue. Adding the `question` label would be helpful.

---

Thank you for your cooperation! 🙏
