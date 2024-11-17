import Cocoa
import KeyboardShortcuts
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  private let mainWindow: Panel = {
    let panel = Panel()
    panel.hidesOnDeactivate = false
    panel.identifier = .main
    panel.level = .screenSaver
    panel.title = "Knobby"
    panel.styleMask = [.utilityWindow, .nonactivatingPanel, .closable]
    panel.hasShadow = false
    panel.backgroundColor = .clear
    panel.titlebarAppearsTransparent = true
    panel.titleVisibility = .hidden
    panel.standardWindowButton(.closeButton)?.isHidden = true
    panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
    panel.standardWindowButton(.zoomButton)?.isHidden = true
    panel.collectionBehavior = [.moveToActiveSpace]
    panel.becomesKeyOnlyIfNeeded = false
    #if DEBUG
      panel.isMovable = true
      panel.isMovableByWindowBackground = true
    #endif
    return panel
  }()

  private let settingsWindow = NSWindow(
    contentRect: .init(origin: .zero, size: .zero),
    styleMask: [.closable, .titled],
    backing: .buffered,
    defer: true
  )

  private let statusItem: NSStatusItem = {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    item.button?.image = NSImage(named: "MenuBarExtra")
    item.button?.image?.isTemplate = true
    #if DEBUG
    item.button?.title = "DEV"
    #endif
    let menu = NSMenu()
    menu.addItem(NSMenuItem(title: "Toggle Knobby", action: #selector(toggleApp), keyEquivalent: ""))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Settings", action: #selector(orderFrontSettingsWindow), keyEquivalent: ","))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Quit Knobby", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    item.menu = menu
    return item
  }()

  private let viewModel = ViewModel()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let appView = NSHostingView(rootView: ContentView(viewModel: viewModel))
    mainWindow.delegate = self
    mainWindow.contentView = appView

    let settingsView = NSHostingView(rootView: SettingsView(statusItem: statusItem).fixedSize())
    settingsWindow.isReleasedWhenClosed = false
    settingsWindow.title = "Knobby Settings"
    settingsWindow.contentView = settingsView

    KeyboardShortcuts.onKeyDown(for: .toggleKnobby) { [weak self] in
      self?.toggleApp(nil)
    }
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    true
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    toggleApp(nil)
    return false
  }

  @objc func toggleApp(_ sender: Any?) {
    viewModel.onToggleApp()
    guard viewModel.isVisible else { return }
    guard let frame = NSScreen.main?.frame else { return assertionFailure() }
    mainWindow.setFrameTopLeftPoint(CGPoint(x: frame.midX - (.knobbyWidth / 2), y: frame.maxY + 1))
    mainWindow.makeKeyAndOrderFront(nil)
  }

  @objc func orderFrontSettingsWindow(_ sender: Any?) {
    NSApplication.shared.activate()
    settingsWindow.makeKeyAndOrderFront(nil)
  }
}

extension AppDelegate: NSWindowDelegate {
  func windowDidResignKey(_ notification: Notification) {
    viewModel.onResignKey()
  }
}
