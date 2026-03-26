import Cocoa
import KeyboardShortcuts
import Observation
import SwiftUI

// MARK: - AppDelegate

@main
final class AppDelegate: NSObject, NSApplicationDelegate {

  // MARK: Internal

  func applicationDidFinishLaunching(_: Notification) {
    NSApplication.shared.setActivationPolicy(.accessory)

    mainWindow.contentViewController = ViewController(model: model)
    mainWindow.delegate = self

    let settingsView = NSHostingView(rootView: SettingsView(statusItem: statusItem).fixedSize())
    settingsWindow.contentView = settingsView

    KeyboardShortcuts.onKeyDown(for: .toggleKnobby) { [weak self] in
      self?.toggleKnobby(nil)
    }

    firstResponderObservation = mainWindow.observe(\.firstResponder, options: [.initial, .new]) { [weak self] window, value in
      Task { @MainActor in
        guard
          let self,
          let viewController = window.contentViewController as? ViewController
        else { return }

        self.model.onFocusedMetricChanged(
          viewController.kind(for: value.newValue ?? window.firstResponder)
        )
      }
    }

    observeMainWindowVisibility()
  }

  func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
    true
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows _: Bool) -> Bool {
    toggleKnobby(sender)
    NSApplication.shared.activate()
    return false
  }

  @objc
  func toggleKnobby(_: Any?) {
    model.onToggleApp()
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
  private var firstResponderObservation: NSKeyValueObservation?
  private var isMainWindowVisible = false

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

  private func observeMainWindowVisibility() {
    withObservationTracking {
      updateMainWindowVisibility()
    } onChange: { [weak self] in
      Task { @MainActor [weak self] in
        self?.observeMainWindowVisibility()
      }
    }
  }

  private func updateMainWindowVisibility() {
    guard model.isVisible != isMainWindowVisible else { return }

    if model.isVisible {
      guard let frame = NSScreen.main?.frame else { return }

      isMainWindowVisible = true
      mainWindow.setFrame(frame, display: true, animate: false)
      mainWindow.alphaValue = 1
      mainWindow.makeKeyAndOrderFront(nil)

      guard
        let viewController = mainWindow.contentViewController as? ViewController,
        let slider = viewController.slider(for: model.focusedSetting)
      else { return }

      mainWindow.makeFirstResponder(slider)
      return
    }

    isMainWindowVisible = false
    mainWindow.orderOut(nil)
    NSApplication.shared.deactivate()
  }

}

// MARK: NSWindowDelegate

extension AppDelegate: NSWindowDelegate {
  func windowDidResignKey(_: Notification) {
    model.onResignKey()
  }
}
