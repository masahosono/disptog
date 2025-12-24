import CoreGraphics

enum DisplayMode {
    case mirroring
    case extended
    case singleDisplay
}

class DisplayManager {
    var currentModeDescription: String {
        switch getCurrentMode() {
        case .mirroring: "🪞 Mirroring"
        case .extended: "📺 Extended Desktop"
        case .singleDisplay: "🖥️ Single Display"
        }
    }

    func getCurrentMode() -> DisplayMode {
        let displayIDs = getOnlineDisplays()
        guard displayIDs.count >= 2 else { return .singleDisplay }

        let mainDisplay = CGMainDisplayID()
        for displayID in displayIDs where displayID != mainDisplay {
            if CGDisplayMirrorsDisplay(displayID) != kCGNullDirectDisplay {
                return .mirroring
            }
        }
        return .extended
    }

    func toggleDisplayMode() -> Bool {
        switch getCurrentMode() {
        case .singleDisplay:
            return false
        case .mirroring:
            return setExtendedMode()
        case .extended:
            return setMirroringMode()
        }
    }

    private func getOnlineDisplays() -> [CGDirectDisplayID] {
        var displayIDs = [CGDirectDisplayID](repeating: 0, count: 16)
        var displayCount: UInt32 = 0

        guard CGGetOnlineDisplayList(16, &displayIDs, &displayCount) == .success else {
            return []
        }
        return Array(displayIDs.prefix(Int(displayCount)))
    }

    private func setMirroringMode() -> Bool {
        let displayIDs = getOnlineDisplays()
        guard displayIDs.count >= 2 else { return false }

        let mainDisplay = CGMainDisplayID()

        var configRef: CGDisplayConfigRef?
        guard CGBeginDisplayConfiguration(&configRef) == .success, let config = configRef else {
            return false
        }

        for displayID in displayIDs where displayID != mainDisplay {
            if CGConfigureDisplayMirrorOfDisplay(config, displayID, mainDisplay) != .success {
                CGCancelDisplayConfiguration(config)
                return false
            }
        }

        return CGCompleteDisplayConfiguration(config, .permanently) == .success
    }

    private func setExtendedMode() -> Bool {
        let displayIDs = getOnlineDisplays()
        guard displayIDs.count >= 2 else { return false }

        var configRef: CGDisplayConfigRef?
        guard CGBeginDisplayConfiguration(&configRef) == .success, let config = configRef else {
            return false
        }

        for displayID in displayIDs {
            if CGConfigureDisplayMirrorOfDisplay(config, displayID, kCGNullDirectDisplay) != .success {
                CGCancelDisplayConfiguration(config)
                return false
            }
        }

        return CGCompleteDisplayConfiguration(config, .permanently) == .success
    }
}
