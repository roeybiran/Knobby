import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  private let mainWindow: Panel = {
    let panel = Panel()
    panel.hidesOnDeactivate = false
    panel.level = .floating
    panel.title = "Knobby"
    panel.styleMask = [.closable, .borderless, .nonactivatingPanel]
    panel.hasShadow = false
    panel.backgroundColor = .clear
    panel.titlebarAppearsTransparent = true
    panel.titleVisibility = .hidden
    panel.standardWindowButton(.closeButton)?.isHidden = true
    panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
    panel.standardWindowButton(.zoomButton)?.isHidden = true
    panel.isFloatingPanel = true
    panel.becomesKeyOnlyIfNeeded = false
    return panel
  }()

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
    menu.addItem(NSMenuItem(title: "Quit Knobby", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    item.menu = menu
    return item
  }()

  private let viewModel = ViewModel()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let hostingView = NSHostingView(rootView: ContentView(viewModel: viewModel, statusItem: statusItem))
    let contentView = NSView()
    contentView.addSubview(hostingView)
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      hostingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      hostingView.topAnchor.constraint(equalTo: contentView.topAnchor)
    ])
    mainWindow.delegate = self
    mainWindow.contentView = contentView
    NSApplication.shared.activate()
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
    if viewModel.isVisible {
      mainWindow.setFrame(NSScreen.main?.visibleFrame ?? .zero, display: true)
      mainWindow.makeKeyAndOrderFront(nil)
    }
  }
}

extension AppDelegate: NSWindowDelegate {
  func windowDidResignKey(_ notification: Notification) {
    viewModel.onResignKey()
  }
}
