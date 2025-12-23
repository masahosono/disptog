# Contributing Guide

Thank you for considering contributing to DispTog! 🎉

## Development Environment Setup

### Requirements

- macOS 11.0 (Big Sur) or later
- Xcode Command Line Tools
- [Mint](https://github.com/yonaskolb/Mint) (Swift tool manager, **required**)

```bash
# Command Line Tools
xcode-select --install

# Install Mint
brew install mint

# Setup development tools
make setup
```

### Build

```bash
# Clone
git clone https://github.com/your-username/disptog.git
cd disptog

# Build
make build

# Run
make run

# Debug (with logs)
make debug
```

## Coding Style

### SwiftLint & SwiftFormat

This project uses SwiftLint (linter) and SwiftFormat (formatter).
Please ensure there are no errors before submitting a pull request.

```bash
# Format (auto-format like Prettier)
make format

# Run lint
make lint

# Auto-fix (auto-fix lint rules)
make lint-fix
```

CI runs `swiftformat --lint` and `swiftlint --strict`.

### Comments

- Write code comments in English
- Try to write explanations that are easy to understand for TypeScript/JavaScript developers
- For complex logic, explain "why" it's done that way

## Pull Request Process

1. Fork this repository
2. Create a feature branch
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. Commit your changes
   ```bash
   git commit -m 'Add amazing feature'
   ```
4. Push to remote
   ```bash
   git push origin feature/amazing-feature
   ```
5. Create a Pull Request

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
- Log output (available via `make debug`)

### Feature Requests

Feature requests are very welcome! However, since this app prioritizes "simplicity," feature additions will be carefully considered.

## Questions

If you have questions, please create an Issue. Adding the `question` label would be helpful.

---

Thank you for your cooperation! 🙏
