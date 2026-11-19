import Carbon
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let displayManager = DisplayManager()
    private var eventHotKeyRef: EventHotKeyRef?
    private var shortcut = Shortcut.load()
    /// Pending task that restores the default icon after the checkmark feedback.
    /// Kept so a new toggle can cancel the previous one (like clearTimeout in JS).
    private var iconResetWorkItem: DispatchWorkItem?

    private static let feedbackDuration: TimeInterval = 2.0
    private static let changelogURL = URL(string: "https://github.com/masahosono/disptog/blob/main/CHANGELOG.md")

    /// Tags used to find menu items that are updated after the menu is built.
    private enum MenuTag {
        static let status = 100
        static let toggle = 101
        static let shortcutInfo = 102
    }

    /// App version from Info.plist (CFBundleShortVersionString), e.g. "1.0.2".
    private static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
    }

    private static func defaultIcon() -> NSImage? {
        NSImage(systemSymbolName: "display.2", accessibilityDescription: "Display Toggle")
    }

    func applicationDidFinishLaunching(_: Notification) {
        setupStatusItem()
        installHotKeyHandler()
        if !registerHotKey(shortcut) {
            // The saved shortcut may now be taken by another app; fall back to the default.
            shortcut = Shortcut.defaultShortcut
            _ = registerHotKey(shortcut)
            updateShortcutMenuItems()
        }
    }

    func applicationWillTerminate(_: Notification) {
        unregisterHotKey()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = AppDelegate.defaultIcon()
        }

        statusItem.menu = createMenu()
    }

    private func createMenu() -> NSMenu {
        let menu = NSMenu()

        let statusMenuItem = NSMenuItem(
            title: "Current: \(displayManager.currentModeDescription)",
            action: nil,
            keyEquivalent: ""
        )
        statusMenuItem.isEnabled = false
        statusMenuItem.tag = MenuTag.status
        menu.addItem(statusMenuItem)

        menu.addItem(NSMenuItem.separator())

        let toggleItem = NSMenuItem(
            title: "🔄 Toggle Mirroring/Extended",
            action: #selector(toggleDisplay),
            keyEquivalent: ""
        )
        toggleItem.tag = MenuTag.toggle
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        let helpItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        helpItem.isEnabled = false
        helpItem.tag = MenuTag.shortcutInfo
        menu.addItem(helpItem)

        let changeShortcutItem = NSMenuItem(
            title: "Change Shortcut…",
            action: #selector(changeShortcut),
            keyEquivalent: ""
        )
        changeShortcutItem.target = self
        menu.addItem(changeShortcutItem)

        menu.addItem(NSMenuItem.separator())

        let versionItem = NSMenuItem(title: "Version \(AppDelegate.appVersion)", action: nil, keyEquivalent: "")
        versionItem.isEnabled = false
        menu.addItem(versionItem)

        let changelogItem = NSMenuItem(title: "What's New (Changelog)…", action: #selector(openChangelog), keyEquivalent: "")
        changelogItem.target = self
        menu.addItem(changelogItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        updateShortcutMenuItems(in: menu)
        return menu
    }

    /// Reflects the current shortcut in the menu (toggle item's key hint and the info line).
    private func updateShortcutMenuItems(in menu: NSMenu? = nil) {
        guard let menu = menu ?? statusItem.menu else { return }
        if let toggleItem = menu.item(withTag: MenuTag.toggle) {
            toggleItem.keyEquivalent = shortcut.character
            toggleItem.keyEquivalentModifierMask = shortcut.menuModifierMask
        }
        menu.item(withTag: MenuTag.shortcutInfo)?.title = "⌨️ Shortcut: \(shortcut.displayString)"
    }

    @objc func toggleDisplay() {
        let success = displayManager.toggleDisplayMode()

        if success {
            if let menu = statusItem.menu, let item = menu.item(withTag: MenuTag.status) {
                item.title = "Current: \(displayManager.currentModeDescription)"
            }

            showToggleFeedback()
        }
    }

    /// Briefly shows a checkmark in the menu bar, then restores the default icon.
    private func showToggleFeedback() {
        guard let button = statusItem.button else { return }

        button.image = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: "Toggled")

        // Always restore the fixed default icon instead of the icon captured at toggle time.
        // Otherwise toggling again while the checkmark is shown would capture the checkmark
        // as the "original" and leave it stuck in the menu bar.
        iconResetWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak button] in
            button?.image = AppDelegate.defaultIcon()
        }
        iconResetWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + AppDelegate.feedbackDuration, execute: workItem)
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    @objc func openChangelog() {
        guard let url = AppDelegate.changelogURL else { return }
        NSWorkspace.shared.open(url)
    }

    // MARK: - Shortcut customization

    /// Asks the user to press a new key combination, shows it for confirmation,
    /// and applies it only when "Save" is clicked.
    @objc func changeShortcut() {
        // Temporarily release the current hotkey so pressing it is recorded
        // instead of toggling the display.
        unregisterHotKey()

        let alert = NSAlert()
        alert.messageText = "Change Shortcut"
        alert.informativeText = """
        Press the new key combination, then click Save.
        It must include ⌘, ⌥, or ⌃.

        Current: \(shortcut.displayString)
        """
        // Button order matters for NSAlert: the first one is the default (Return),
        // and a button titled "Cancel" is triggered by Escape.
        let saveButton = alert.addButton(withTitle: "Save")
        saveButton.isEnabled = false // Enabled once a valid combination is pressed
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Reset to Default")

        // NSAlert's informativeText is laid out once when the alert is shown, so the
        // live preview goes into a separate label (accessory view) that we can update.
        let previewLabel = NSTextField(labelWithString: "New: —")
        previewLabel.font = NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .semibold)
        previewLabel.frame = NSRect(x: 0, y: 0, width: 260, height: 20)
        alert.accessoryView = previewLabel

        // A "local monitor" sees key events of this app before they are dispatched
        // (similar to a capturing keydown listener in JS). It also runs while the alert
        // is shown modally, so we can record key presses without closing the alert.
        var recorded: Shortcut?
        let monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            if let candidate = Shortcut(event: event) {
                // Check availability now (register + release) so the user sees a conflict
                // before confirming, instead of after.
                if self.registerHotKey(candidate) {
                    self.unregisterHotKey()
                    recorded = candidate
                    previewLabel.stringValue = "New: \(candidate.displayString)"
                    saveButton.isEnabled = true
                } else {
                    recorded = nil
                    previewLabel.stringValue = "\(candidate.displayString) is already in use"
                    saveButton.isEnabled = false
                }
                return nil // Swallow the event
            }
            // Let Return / Escape reach the alert (Save / Cancel); ignore other plain keys.
            if [kVK_Return, kVK_ANSI_KeypadEnter, kVK_Escape].contains(Int(event.keyCode)) {
                return event
            }
            NSSound.beep()
            return nil
        }

        // Menu bar–only apps are not active by default; bring the alert to the front.
        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }

        let previous = shortcut
        let candidate: Shortcut
        if response == .alertFirstButtonReturn, let recorded {
            candidate = recorded
        } else if response == .alertThirdButtonReturn {
            candidate = Shortcut.defaultShortcut
        } else {
            _ = registerHotKey(previous)
            return
        }

        if registerHotKey(candidate) {
            shortcut = candidate
            shortcut.save()
            updateShortcutMenuItems()
        } else {
            _ = registerHotKey(previous)
            showShortcutUnavailableAlert(candidate)
        }
    }

    private func showShortcutUnavailableAlert(_ candidate: Shortcut) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Shortcut Unavailable"
        alert.informativeText = "\(candidate.displayString) is already used by the system or another app. The shortcut was not changed."
        alert.runModal()
    }

    // MARK: - Global hotkey (Carbon)

    /// Registers the given shortcut as a system-wide hotkey. Returns false on failure,
    /// e.g. when another app already registered the same combination.
    private func registerHotKey(_ shortcut: Shortcut) -> Bool {
        unregisterHotKey()

        // The signature is an arbitrary four-char code identifying our app ("DTOG").
        let hotKeyID = EventHotKeyID(signature: OSType(0x4454_4F47), id: 1)
        let status = RegisterEventHotKey(
            shortcut.keyCode,
            shortcut.carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &eventHotKeyRef
        )
        if status != noErr {
            eventHotKeyRef = nil
            return false
        }
        return true
    }

    private func unregisterHotKey() {
        if let hotKeyRef = eventHotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            eventHotKeyRef = nil
        }
    }

    /// Installs the hotkey-pressed callback once. It stays valid when the hotkey itself
    /// is re-registered with a different key combination.
    private func installHotKeyHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, _ -> OSStatus in
                DispatchQueue.main.async {
                    (NSApplication.shared.delegate as? AppDelegate)?.toggleDisplay()
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )
    }
}

@main
struct DispTogMain {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}
