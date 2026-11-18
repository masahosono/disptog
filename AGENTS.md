# AGENTS.md

Guidance for AI coding agents working in this repository.

## Project Overview

DispTog is a small macOS menu bar app (Swift / AppKit) that toggles display
**mirroring / extended** mode with one click or a global shortcut (`⌘⇧M`).
The app prioritizes simplicity — avoid adding features, dependencies, or
abstractions unless explicitly requested.

- Target: macOS 11.0+, Swift 5
- Frameworks: Cocoa, CoreGraphics, Carbon (no third-party runtime dependencies)
- The app runs as a menu bar–only app (hidden from the Dock via `setActivationPolicy(.accessory)`)

## Repository Layout

| Path | Purpose |
|------|---------|
| `Sources/DispTogApp.swift` | Entry point / `AppDelegate`: status item, menu, global hotkey (Carbon `RegisterEventHotKey`) |
| `Sources/DisplayManager.swift` | Display logic: reads online displays and switches mirroring/extended via CoreGraphics display configuration APIs |
| `Sources/Info.plist` | App configuration |
| `Resources/` | App icon (`AppIcon.icns`, `icon_1024.png`) |
| `project.yml` | XcodeGen spec — the source of truth for the Xcode project |
| `Package.swift` | SPM package used **only** to run SwiftLint / SwiftFormat; it has no app targets |
| `.github/workflows/check.yml` | PR CI: format check, lint, debug build |
| `.github/workflows/build.yml` | Release CD: builds Release and uploads a DMG when a GitHub Release is published |

`DispTog.xcodeproj` is generated and git-ignored. Never edit or commit it;
change `project.yml` and regenerate instead.

## Setup & Build

```bash
brew install xcodegen          # once
xcodegen generate              # after cloning or changing project.yml
swift package resolve          # for lint/format tools

# Debug build (same as CI)
xcodebuild -project DispTog.xcodeproj -scheme DispTog -configuration Debug -derivedDataPath build build

# Run
open build/Build/Products/Debug/DispTog.app
```

## Checks (must pass before finishing a change)

CI runs these exact commands; run them locally too:

```bash
swift run swiftformat --lint .
swift run swiftlint --strict
xcodebuild -project DispTog.xcodeproj -scheme DispTog -configuration Debug -derivedDataPath build build
```

Use `swift run swiftformat .` to auto-format. Note that `--strict` turns
SwiftLint warnings (e.g. `force_unwrapping`) into errors.

There is no automated test target. Display switching requires two or more
physical displays, so verify behavior manually when possible and state clearly
when it could not be verified.

## Coding Conventions

- Follow `.swiftformat` and `.swiftlint.yml` (4-space indent, no forced
  unwrapping, prefer `isEmpty`, etc.).
- Write code comments in **English**.
- Comments are intended to be approachable for TypeScript/JavaScript
  developers; explain the "why" for non-obvious logic (especially CoreGraphics
  and Carbon APIs).
- Keep the two-file structure unless a change clearly warrants a new file. If
  you add a source file, update the "Project Structure" section in `README.md`.

## Commits & Pull Requests

- Use Conventional Commit–style prefixes: `feat:`, `fix:`, `docs:`,
  `refactor:`, `style:`, `test:`, `chore:`.
- PRs target `main`; the `Check` workflow must pass.
- Releases are created by publishing a GitHub Release with a `vX.Y.Z` tag;
  do not create releases or tags unless asked.

## Notes

- The global shortcut may require Accessibility permission
  (System Settings > Privacy & Security > Accessibility).
- Keep `README.md`, `README_ja.md` (Japanese translation), and
  `CONTRIBUTING.md` consistent with any changes to build steps, shortcuts, or
  structure. When editing `README.md`, apply the same change to `README_ja.md`.
