import Cocoa
import KeyboardShortcuts
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  private let mainWindow = NSWindow.main
  private let settingsWindow = NSWindow.settings
  private let model = Model()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    NSApplication.shared.setActivationPolicy(.accessory)

    mainWindow.contentView = NSHostingView(rootView: ContentView(model: model))
    mainWindow.setContentSize(
      mainWindow.contentView?.fittingSize ?? .init(width: .knobbyWidth, height: 0)
    )
    mainWindow.delegate = self

    let settingsView = NSHostingView(rootView: SettingsView(statusItem: statusItem).fixedSize())
    settingsWindow.contentView = settingsView

    KeyboardShortcuts.onKeyDown(for: .toggleKnobby) { [weak self] in
      self?.toggleKnobby(nil)
    }
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    true
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    toggleKnobby(sender)
    NSApplication.shared.activate()
    return false
  }

  @objc func toggleKnobby(_ sender: Any?) {
    model.onToggleApp()

    if model.isVisible {
      mainWindow.contentView?.layoutSubtreeIfNeeded()
      mainWindow.setContentSize(
        mainWindow.contentView?.fittingSize ?? .init(width: .knobbyWidth, height: 0)
      )
      mainWindow.makeKeyAndOrderFront(nil)
    } else {
      mainWindow.orderOut(nil)
    }
  }

  @IBAction func orderFrontSettingsWindow(_ sender: Any?) {
    settingsWindow.makeKeyAndOrderFront(sender)
    settingsWindow.orderFrontRegardless()
  }

  private let statusItem: NSStatusItem = {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    item.button?.image = NSImage(named: "MenuBarExtra")
    item.button?.image?.isTemplate = true
    #if DEBUG
    item.button?.title = "DEV"
    #endif
    item.menu = .general()
    return item
  }()
}

extension AppDelegate: NSWindowDelegate {
  func windowDidResignKey(_ notification: Notification) {
    model.onResignKey()
    mainWindow.orderOut(nil)
  }
}
