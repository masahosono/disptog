import Carbon
import Cocoa

/// A user-configurable global shortcut.
///
/// Carbon's `RegisterEventHotKey` identifies keys by a hardware "virtual key code"
/// (layout independent, e.g. 46 is the physical M key on US layouts) and by its own
/// modifier bit flags (`cmdKey`, `shiftKey`, ...), which differ from AppKit's
/// `NSEvent.ModifierFlags`. This struct stores the Carbon values and converts as needed.
struct Shortcut: Equatable {
    /// Carbon virtual key code (e.g. `kVK_ANSI_M`).
    let keyCode: UInt32
    /// Carbon modifier flags (combination of `cmdKey`, `shiftKey`, `optionKey`, `controlKey`).
    let carbonModifiers: UInt32
    /// The character produced by the key without modifiers (e.g. "m").
    /// Used as the menu item's key equivalent and as a fallback display label.
    let character: String

    static let defaultShortcut = Shortcut(
        keyCode: UInt32(kVK_ANSI_M),
        carbonModifiers: UInt32(cmdKey | shiftKey),
        character: "m"
    )

    // MARK: - Creating from a key event

    /// Builds a shortcut from a key-down event, or returns nil when the combination is not
    /// suitable as a global shortcut. At least one of ⌘ / ⌥ / ⌃ is required so that plain
    /// typing (or Shift + letter) is never swallowed system-wide.
    init?(event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        guard !flags.isDisjoint(with: [.command, .option, .control]) else { return nil }

        var modifiers: UInt32 = 0
        if flags.contains(.command) { modifiers |= UInt32(cmdKey) }
        if flags.contains(.shift) { modifiers |= UInt32(shiftKey) }
        if flags.contains(.option) { modifiers |= UInt32(optionKey) }
        if flags.contains(.control) { modifiers |= UInt32(controlKey) }

        // `characters(byApplyingModifiers: [])` gives the base character for the current
        // keyboard layout (e.g. "1" rather than "!" when Shift is held).
        let base = event.characters(byApplyingModifiers: []) ?? ""
        self.init(keyCode: UInt32(event.keyCode), carbonModifiers: modifiers, character: base.lowercased())
    }

    init(keyCode: UInt32, carbonModifiers: UInt32, character: String) {
        self.keyCode = keyCode
        self.carbonModifiers = carbonModifiers
        self.character = character
    }

    // MARK: - Persistence (UserDefaults, similar to localStorage in JS)

    private enum DefaultsKey {
        static let keyCode = "shortcut.keyCode"
        static let modifiers = "shortcut.modifiers"
        static let character = "shortcut.character"
    }

    /// Returns the saved shortcut, or the default when nothing has been saved yet.
    static func load(from defaults: UserDefaults = .standard) -> Shortcut {
        guard
            let keyCode = defaults.object(forKey: DefaultsKey.keyCode) as? Int,
            let modifiers = defaults.object(forKey: DefaultsKey.modifiers) as? Int,
            let character = defaults.string(forKey: DefaultsKey.character)
        else {
            return defaultShortcut
        }
        return Shortcut(keyCode: UInt32(keyCode), carbonModifiers: UInt32(modifiers), character: character)
    }

    func save(to defaults: UserDefaults = .standard) {
        defaults.set(Int(keyCode), forKey: DefaultsKey.keyCode)
        defaults.set(Int(carbonModifiers), forKey: DefaultsKey.modifiers)
        defaults.set(character, forKey: DefaultsKey.character)
    }

    // MARK: - Display

    /// AppKit modifier flags, used for `NSMenuItem.keyEquivalentModifierMask`.
    var menuModifierMask: NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []
        if carbonModifiers & UInt32(cmdKey) != 0 { flags.insert(.command) }
        if carbonModifiers & UInt32(shiftKey) != 0 { flags.insert(.shift) }
        if carbonModifiers & UInt32(optionKey) != 0 { flags.insert(.option) }
        if carbonModifiers & UInt32(controlKey) != 0 { flags.insert(.control) }
        return flags
    }

    /// Human-readable label such as "⌘⇧M", using the standard macOS modifier order (⌃⌥⇧⌘).
    var displayString: String {
        var result = ""
        if carbonModifiers & UInt32(controlKey) != 0 { result += "⌃" }
        if carbonModifiers & UInt32(optionKey) != 0 { result += "⌥" }
        if carbonModifiers & UInt32(shiftKey) != 0 { result += "⇧" }
        if carbonModifiers & UInt32(cmdKey) != 0 { result += "⌘" }
        return result + keyLabel
    }

    /// Keys that don't produce a readable character (arrows, F-keys, ...) need explicit names.
    private static let specialKeyLabels: [Int: String] = [
        kVK_Space: "Space", kVK_Return: "↩", kVK_Tab: "⇥", kVK_Delete: "⌫",
        kVK_ForwardDelete: "⌦", kVK_Escape: "⎋", kVK_Home: "↖", kVK_End: "↘",
        kVK_PageUp: "⇞", kVK_PageDown: "⇟",
        kVK_LeftArrow: "←", kVK_RightArrow: "→", kVK_UpArrow: "↑", kVK_DownArrow: "↓",
        kVK_F1: "F1", kVK_F2: "F2", kVK_F3: "F3", kVK_F4: "F4", kVK_F5: "F5", kVK_F6: "F6",
        kVK_F7: "F7", kVK_F8: "F8", kVK_F9: "F9", kVK_F10: "F10", kVK_F11: "F11", kVK_F12: "F12"
    ]

    private var keyLabel: String {
        if let label = Shortcut.specialKeyLabels[Int(keyCode)] {
            return label
        }
        return character.isEmpty ? "Key \(keyCode)" : character.uppercased()
    }
}
