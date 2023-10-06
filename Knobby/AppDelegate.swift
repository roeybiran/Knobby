import Cocoa
import SwiftUI

//https://cindori.com/developer/floating-panel
@main
class AppDelegate: NSObject, NSApplicationDelegate {
  private lazy var mainWindow = Panel()

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

    #if DEBUG
    toggleApp(nil)
    #endif
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool { true }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    toggleApp(nil)
    return false
  }

  @objc func toggleApp(_ sender: Any?) {
    if viewModel.isVisible {
      viewModel.isVisible = false
    } else {
      mainWindow.makeKeyAndOrderFront(nil)
      viewModel.isVisible = true
    }
  }
}


extension AppDelegate: NSWindowDelegate {
  func windowDidBecomeKey(_ notification: Notification) {
    guard let window = notification.object as? NSWindow else { return assertionFailure() }
    window.setFrame(NSScreen.main?.visibleFrame ?? .zero, display: true)
    viewModel.onAppear()
  }

  func windowDidResignKey(_ notification: Notification) {
    viewModel.isVisible = false
  }
}
