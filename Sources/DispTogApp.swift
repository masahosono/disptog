import Carbon
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let displayManager = DisplayManager()
    private var eventHotKeyRef: EventHotKeyRef?
    /// Pending task that restores the default icon after the checkmark feedback.
    /// Kept so a new toggle can cancel the previous one (like clearTimeout in JS).
    private var iconResetWorkItem: DispatchWorkItem?

    private static let feedbackDuration: TimeInterval = 2.0

    private static func defaultIcon() -> NSImage? {
        NSImage(systemSymbolName: "display.2", accessibilityDescription: "Display Toggle")
    }

    func applicationDidFinishLaunching(_: Notification) {
        setupStatusItem()
        registerGlobalShortcut()
    }

    func applicationWillTerminate(_: Notification) {
        if let hotKeyRef = eventHotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
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
        statusMenuItem.tag = 100
        menu.addItem(statusMenuItem)

        menu.addItem(NSMenuItem.separator())

        let toggleItem = NSMenuItem(
            title: "🔄 Toggle Mirroring/Extended",
            action: #selector(toggleDisplay),
            keyEquivalent: "m"
        )
        toggleItem.keyEquivalentModifierMask = [.command, .shift]
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        let helpItem = NSMenuItem(title: "⌨️ Shortcut: ⌘⇧M", action: nil, keyEquivalent: "")
        helpItem.isEnabled = false
        menu.addItem(helpItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    @objc func toggleDisplay() {
        let success = displayManager.toggleDisplayMode()

        if success {
            if let menu = statusItem.menu, let item = menu.item(withTag: 100) {
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

    private func registerGlobalShortcut() {
        let hotKeyID = EventHotKeyID(signature: OSType(0x4454_4F47), id: 1)
        let status = RegisterEventHotKey(
            46, // M key
            UInt32(cmdKey | shiftKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &eventHotKeyRef
        )

        guard status == noErr else { return }

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
