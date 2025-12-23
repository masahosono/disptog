// DisplayManager.swift
// Class that manages display mirroring/extended mode
//
// This file handles the logic for getting and changing display state
// using macOS CoreGraphics framework.
// It's similar to a service class in TypeScript.

import Cocoa
import CoreGraphics

// MARK: - Display Mode Enum

/// Enum representing display mode
/// Similar to `enum` or Union Type in TypeScript
enum DisplayMode {
    case mirroring // Mirroring mode
    case extended // Extended mode
    case singleDisplay // Single display only
}

// MARK: - Display Manager Class

/// Class that manages display mirroring/extended mode
class DisplayManager {
    // MARK: - Properties

    /// Returns description of current mode (read-only)
    /// Similar to getter in TypeScript
    var currentModeDescription: String {
        switch getCurrentMode() {
        case .mirroring:
            "🪞 Mirroring"
        case .extended:
            "📺 Extended Desktop"
        case .singleDisplay:
            "🖥️ Single Display"
        }
    }

    // MARK: - Initialization

    init() {
        print("📺 DisplayManager initialized")
        printDisplayInfo()
    }

    // MARK: - Public Methods

    /// Get current display mode
    /// - Returns: Current display mode
    func getCurrentMode() -> DisplayMode {
        // Get online display IDs
        let displayIDs = getOnlineDisplays()

        // If 1 or fewer displays
        guard displayIDs.count >= 2 else {
            return .singleDisplay
        }

        // Check mirroring status
        // CGDisplayMirrorsDisplay returns the ID of the display being mirrored
        // (returns kCGNullDirectDisplay if not mirroring)
        let mainDisplay = CGMainDisplayID()

        for displayID in displayIDs where displayID != mainDisplay {
            let mirroredDisplay = CGDisplayMirrorsDisplay(displayID)
            if mirroredDisplay != kCGNullDirectDisplay {
                return .mirroring
            }
        }

        return .extended
    }

    /// Toggle display mode
    /// - Returns: true if successful
    func toggleDisplayMode() -> Bool {
        let currentMode = getCurrentMode()

        switch currentMode {
        case .singleDisplay:
            print("⚠️ Only one display is connected")
            return false

        case .mirroring:
            // Switch from Mirroring to Extended
            return setExtendedMode()

        case .extended:
            // Switch from Extended to Mirroring
            return setMirroringMode()
        }
    }

    // MARK: - Private Methods

    /// Get list of online display IDs
    /// - Returns: Array of display IDs
    private func getOnlineDisplays() -> [CGDirectDisplayID] {
        // Support up to 16 displays
        var displayIDs = [CGDirectDisplayID](repeating: 0, count: 16)
        var displayCount: UInt32 = 0

        // Get online displays
        let result = CGGetOnlineDisplayList(16, &displayIDs, &displayCount)

        guard result == .success else {
            print("❌ Failed to get display list: \(result)")
            return []
        }

        // Return only valid display IDs
        return Array(displayIDs.prefix(Int(displayCount)))
    }

    /// Set mirroring mode
    /// - Returns: true if successful
    private func setMirroringMode() -> Bool {
        print("🔄 Switching to mirroring mode...")

        let displayIDs = getOnlineDisplays()
        guard displayIDs.count >= 2 else { return false }

        // Get main display
        let mainDisplay = CGMainDisplayID()

        // Start display configuration transaction
        // This is a mechanism to apply multiple changes together
        var configRef: CGDisplayConfigRef?
        var result = CGBeginDisplayConfiguration(&configRef)

        guard result == .success, let config = configRef else {
            print("❌ Failed to start configuration")
            return false
        }

        // Set all displays except main to mirror
        for displayID in displayIDs where displayID != mainDisplay {
            // Set this display to mirror main display
            result = CGConfigureDisplayMirrorOfDisplay(config, displayID, mainDisplay)
            if result != .success {
                print("❌ Failed to configure mirroring: \(displayID)")
                CGCancelDisplayConfiguration(config)
                return false
            }
        }

        // Apply configuration
        result = CGCompleteDisplayConfiguration(config, .permanently)

        if result == .success {
            print("✅ Successfully switched to mirroring mode")
            return true
        } else {
            print("❌ Failed to apply configuration")
            return false
        }
    }

    /// Set extended desktop mode
    /// - Returns: true if successful
    private func setExtendedMode() -> Bool {
        print("🔄 Switching to extended desktop mode...")

        let displayIDs = getOnlineDisplays()
        guard displayIDs.count >= 2 else { return false }

        // Start display configuration transaction
        var configRef: CGDisplayConfigRef?
        var result = CGBeginDisplayConfiguration(&configRef)

        guard result == .success, let config = configRef else {
            print("❌ Failed to start configuration")
            return false
        }

        // Disable mirroring for all displays
        // Specifying kCGNullDirectDisplay disables mirroring
        for displayID in displayIDs {
            result = CGConfigureDisplayMirrorOfDisplay(config, displayID, kCGNullDirectDisplay)
            if result != .success {
                print("❌ Failed to disable mirroring: \(displayID)")
                CGCancelDisplayConfiguration(config)
                return false
            }
        }

        // Apply configuration
        result = CGCompleteDisplayConfiguration(config, .permanently)

        if result == .success {
            print("✅ Successfully switched to extended desktop mode")
            return true
        } else {
            print("❌ Failed to apply configuration")
            return false
        }
    }

    // MARK: - Debug

    /// Output current display information
    private func printDisplayInfo() {
        let displayIDs = getOnlineDisplays()
        print("📊 Connected displays: \(displayIDs.count)")

        for (index, displayID) in displayIDs.enumerated() {
            let isMain = (displayID == CGMainDisplayID()) ? " (Main)" : ""
            let mirroredID = CGDisplayMirrorsDisplay(displayID)
            let mirrorStatus = (mirroredID != kCGNullDirectDisplay) ? " [Mirror: \(mirroredID)]" : ""

            print("  \(index + 1). ID: \(displayID)\(isMain)\(mirrorStatus)")
        }
    }
}
