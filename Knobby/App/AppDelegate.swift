import Cocoa
import KeyboardShortcuts
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  private let mainWindow = NSWindow.main
  private let settingsWindow = NSWindow.settings
  private let model = Model()
  private var observation: NSKeyValueObservation?

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    NSApplication.shared.setActivationPolicy(.accessory)

    mainWindow.contentViewController = ViewController(model: model)
    mainWindow.delegate = self

    let settingsView = NSHostingView(rootView: SettingsView(statusItem: statusItem).fixedSize())
    settingsWindow.contentView = settingsView

    KeyboardShortcuts.onKeyDown(for: .toggleKnobby) { [weak self] in
      self?.toggleKnobby(nil)
    }

    observation = mainWindow.observe(\.firstResponder, options: [.initial, .new]) { [weak self] window, value in
      self?.model.onFocusedSliderChanged(change: value)
    }

    withObservationTracking(of: self.model.isVisible) { [weak self] visible in
      guard let self else { return }
      guard let frame = NSScreen.main?.frame else { return assertionFailure() }
      Task { @MainActor in
        if visible {
          self.mainWindow.setFrame(frame, display: true, animate: false)
          self.mainWindow.makeKeyAndOrderFront(nil)
          self.mainWindow.animator().alphaValue = 1
        } else {
          self.mainWindow.animator().alphaValue = 0
          NSApplication.shared.deactivate()
        }
      }
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
  }
}
