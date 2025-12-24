import Carbon
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let displayManager = DisplayManager()
    private var eventHotKeyRef: EventHotKeyRef?

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
            button.image = NSImage(systemSymbolName: "display.2", accessibilityDescription: "Display Toggle")
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

            // Visual feedback
            if let button = statusItem.button {
                let original = button.image
                button.image = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    button.image = original
                }
            }
        }
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
