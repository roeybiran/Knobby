import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  lazy var windowController = MainWindowController()

  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  private let viewModel = ViewModel()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    statusItem.button?.image = NSImage(named: "MenuBarExtra")
    statusItem.button?.image?.isTemplate = true
    statusItem.button?.target = self
    let menu = NSMenu()
    menu.addItem(NSMenuItem(title: "Toggle Knobby", action: #selector(toggleApp), keyEquivalent: ""))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Quit Knobby", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    statusItem.menu = menu

    let mainView = NSHostingView(rootView: MainView(viewModel: viewModel, statusItem: statusItem))
    let mainViewController = MainViewController(contentView: mainView)
    windowController.viewModel = viewModel
    windowController.contentViewController = mainViewController

    #if DEBUG
    windowController.showWindow(nil)
    #endif
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    toggleApp(nil)
    return false
  }

  @objc func toggleApp(_ sender: Any?) {
    let isVisible = windowController.window?.isVisible ?? false
    if isVisible {
      windowController.close()
    } else {
      windowController.showWindow(nil)
    }
  }
}

