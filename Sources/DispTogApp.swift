// DispTogApp.swift
// Menu bar app for toggling display mirroring/extended mode
//
// This file is the main entry point of the application.
// It's similar to `index.ts` in TypeScript.

import Carbon // For global shortcut
import Cocoa // macOS UI framework (AppKit)

// MARK: - Main Application Class

/// AppDelegate is a class that manages the application lifecycle.
/// In TypeScript terms, it's like a singleton that manages the entire app.
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Properties

    /// The item (icon) displayed in the menu bar
    /// `!` means "will never be nil" (similar to `!` in TypeScript)
    private var statusItem: NSStatusItem!

    /// Instance of the display management class
    private let displayManager = DisplayManager()

    /// Event handler ID for global shortcut
    private var eventHotKeyRef: EventHotKeyRef?

    // MARK: - Lifecycle Methods

    /// Method called when application launch is complete
    /// Similar to `onMount` or `useEffect(() => {}, [])` in TypeScript
    func applicationDidFinishLaunching(_: Notification) {
        // Create menu bar item
        setupStatusItem()

        // Register global shortcut (Command + Shift + M)
        registerGlobalShortcut()

        print("✅ DispTog has started")
    }

    /// Method called when application terminates
    func applicationWillTerminate(_: Notification) {
        // Unregister shortcut
        unregisterGlobalShortcut()
        print("👋 DispTog is terminating")
    }

    // MARK: - Menu Bar Setup

    /// Method to create and configure the menu bar item (icon)
    private func setupStatusItem() {
        // Add item to system menu bar
        // `.variableLength` is a setting that adjusts width based on content
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // Configure icon (button)
        if let button = statusItem.button {
            // Use SF Symbols display icon
            // System icon available on macOS 11 and later
            button.image = NSImage(systemSymbolName: "display.2", accessibilityDescription: "Display Toggle")
            button.toolTip = "Click to toggle display mode"
        }

        // Create and set menu
        statusItem.menu = createMenu()
    }

    /// Method to create dropdown menu
    /// Similar to a function that returns a component when using React in TypeScript
    private func createMenu() -> NSMenu {
        let menu = NSMenu()

        // Current mode display (not clickable)
        let statusMenuItem = NSMenuItem(
            title: "Current: \(displayManager.currentModeDescription)",
            action: nil, // No action
            keyEquivalent: ""
        )
        statusMenuItem.isEnabled = false
        statusMenuItem.tag = 100 // Tag for later updates
        menu.addItem(statusMenuItem)

        // Separator
        menu.addItem(NSMenuItem.separator())

        // Toggle button
        let toggleItem = NSMenuItem(
            title: "🔄 Toggle Mirroring/Extended",
            action: #selector(toggleDisplay), // Method to call on click
            keyEquivalent: "m" // Shortcut key (only when menu is shown)
        )
        toggleItem.keyEquivalentModifierMask = [.command, .shift]
        toggleItem.target = self // Call this class's method
        menu.addItem(toggleItem)

        // Separator
        menu.addItem(NSMenuItem.separator())

        // Help information
        let helpItem = NSMenuItem(
            title: "⌨️ Shortcut: ⌘⇧M",
            action: nil,
            keyEquivalent: ""
        )
        helpItem.isEnabled = false
        menu.addItem(helpItem)

        // Separator
        menu.addItem(NSMenuItem.separator())

        // Quit button
        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    // MARK: - Action Methods

    /// Method to toggle display mode
    /// `@objc` is a marker to make it callable from Objective-C
    /// Required because menu item actions use Objective-C selectors
    @objc func toggleDisplay() {
        print("🔄 Toggling display mode...")

        // Execute display toggle
        let success = displayManager.toggleDisplayMode()

        if success {
            // Update status display in menu
            updateStatusMenuItem()

            // Show notification (optional)
            showNotification(
                title: "Display Mode Changed",
                message: displayManager.currentModeDescription
            )
        } else {
            showNotification(
                title: "Error",
                message: "Failed to change display mode"
            )
        }
    }

    /// Method to quit the application
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - UI Update

    /// Method to update status display in menu
    private func updateStatusMenuItem() {
        // Find and update item with tag 100
        if let menu = statusItem.menu,
           let statusMenuItem = menu.item(withTag: 100) {
            statusMenuItem.title = "Current: \(displayManager.currentModeDescription)"
        }
    }

    // MARK: - Notification

    /// Method to show system notification
    /// Note: Since notifications are optional, simply output to standard output
    /// For full notifications, use the UserNotifications framework
    private func showNotification(title: String, message: String) {
        // Output to console (for debugging)
        print("📢 \(title): \(message)")

        // Temporarily change menu bar icon as visual feedback
        if let button = statusItem.button {
            let originalImage = button.image
            button.image = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: "Success")

            // Revert to original icon after 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                button.image = originalImage
            }
        }
    }

    // MARK: - Global Shortcut

    /// Method to register global shortcut (Command + Shift + M)
    /// Works even when app is in background
    private func registerGlobalShortcut() {
        // Hot key ID (arbitrary 4 characters)
        let hotKeyID = EventHotKeyID(signature: OSType(0x4454_4F47), id: 1) // "DTOG"

        // Key code: M = 46
        // Modifiers: Command + Shift
        let modifiers = UInt32(cmdKey | shiftKey)
        let keyCode: UInt32 = 46 // M key

        // Register hot key
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &eventHotKeyRef
        )

        if status == noErr {
            print("✅ Global shortcut registered successfully: ⌘⇧M")

            // Install event handler
            installHotKeyHandler()
        } else {
            print("❌ Failed to register global shortcut")
        }
    }

    /// Install hot key event handler
    private func installHotKeyHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        // Install event handler
        // Slightly complex due to calling from Swift
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, _ -> OSStatus in
                // Processing when hot key is pressed
                // Call AppDelegate's toggleDisplay
                DispatchQueue.main.async {
                    if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                        appDelegate.toggleDisplay()
                    }
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )
    }

    /// Unregister global shortcut
    private func unregisterGlobalShortcut() {
        if let hotKeyRef = eventHotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            print("✅ Global shortcut unregistered")
        }
    }
}

// MARK: - Application Entry Point

/// Struct that launches the application
/// `@main` indicates this struct is the app's entry point
/// Similar to `main()` function in TypeScript
@main
struct DispTogMain {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate

        // Setting to not show icon in Dock
        // Menu bar apps typically don't show in Dock
        app.setActivationPolicy(.accessory)

        // Run application
        app.run()
    }
}
