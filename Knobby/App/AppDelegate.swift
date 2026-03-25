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
      showMainWindow()
    } else {
      hideMainWindow(deactivateApp: true)
    }
  }

  @objc func dismissKnobby(_ sender: Any?) {
    if model.isVisible {
      model.onEscapePress()
    }
    hideMainWindow(deactivateApp: true)
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

  private func showMainWindow() {
    mainWindow.contentView?.layoutSubtreeIfNeeded()
    mainWindow.setContentSize(
      mainWindow.contentView?.fittingSize ?? .init(width: .knobbyWidth, height: 0)
    )
    if let screen = mainWindow.screen
      ?? NSScreen.screens.first(where: { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) })
      ?? NSScreen.main
    {
      let visibleFrame = screen.visibleFrame
      mainWindow.setFrameTopLeftPoint(
        .init(
          x: round(visibleFrame.midX - mainWindow.frame.width / 2),
          y: round(visibleFrame.maxY)
        )
      )
    }
    mainWindow.alphaValue = 0
    mainWindow.makeKeyAndOrderFront(nil)
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.3
      mainWindow.animator().alphaValue = 1
    }
  }

  private func hideMainWindow(deactivateApp: Bool) {
    guard mainWindow.isVisible else { return }

    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.3
      mainWindow.animator().alphaValue = 0
    } completionHandler: {
      self.mainWindow.orderOut(nil)
      self.mainWindow.alphaValue = 1
      if deactivateApp {
        NSApplication.shared.deactivate()
      }
    }
  }
}

extension AppDelegate: NSWindowDelegate {
  func windowDidResignKey(_ notification: Notification) {
    model.onResignKey()
    hideMainWindow(deactivateApp: false)
  }
}
