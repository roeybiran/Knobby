import Cocoa
import KeyboardShortcuts
import SwiftUI

// MARK: - AppDelegate

@main
final class AppDelegate: NSObject, NSApplicationDelegate {

  // MARK: Internal

  func applicationDidFinishLaunching(_: Notification) {
    NSApplication.shared.setActivationPolicy(.accessory)

    mainWindow.contentViewController = ViewController(model: model) { [weak self] in
      self?.dismissKnobby()
    }
    mainWindow.delegate = self

    let settingsView = NSHostingView(rootView: SettingsView(statusItem: statusItem).fixedSize())
    settingsWindow.contentView = settingsView

    KeyboardShortcuts.onKeyDown(for: .toggleKnobby) { [weak self] in
      self?.toggleKnobby(nil)
    }
  }

  func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
    true
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows _: Bool) -> Bool {
    if !isVisible {
      showKnobby()
    }
    NSApplication.shared.activate()
    return false
  }

  @objc
  func toggleKnobby(_: Any?) {
    if isVisible {
      dismissKnobby()
    } else {
      showKnobby()
    }
  }

  @IBAction
  func orderFrontSettingsWindow(_ sender: Any?) {
    settingsWindow.makeKeyAndOrderFront(sender)
    settingsWindow.orderFrontRegardless()
  }

  // MARK: Private

  private let mainWindow = NSWindow.main
  private let settingsWindow = NSWindow.settings
  private let model = Model()
  private var isVisible = false

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

  private func showKnobby() {
    guard let frame = NSScreen.main?.frame else { return }

    mainWindow.setFrame(frame, display: true, animate: false)
    mainWindow.alphaValue = 1
    mainWindow.makeKeyAndOrderFront(nil)
  }

  private func dismissKnobby() {
    guard isVisible else { return }
    isVisible = false
    mainWindow.orderOut(nil)
    NSApplication.shared.deactivate()
  }

}

// MARK: NSWindowDelegate

extension AppDelegate: NSWindowDelegate {
  func windowDidBecomeKey(_: Notification) {
    isVisible = true
    model.refresh()

    guard
      let viewController = mainWindow.contentViewController as? ViewController,
      let slider = viewController.slider(for: model.focusedSetting)
    else { return }

    mainWindow.makeFirstResponder(slider)
  }

  func windowDidResignKey(_: Notification) {
    dismissKnobby()
  }
}
