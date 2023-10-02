import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  lazy var windowController = MainWindowController()

  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    statusItem.button?.image = NSImage(systemSymbolName: "slider.horizontal.2.square", accessibilityDescription: nil)
    statusItem.button?.image?.isTemplate = true
    statusItem.button?.target = self
    let menu = NSMenu()
    menu.addItem(NSMenuItem(title: "Toggle Knobby", action: #selector(toggleApp), keyEquivalent: ""))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Quit Knobby", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    statusItem.menu = menu
    
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

