import AppKit

extension NSMenu {
  static func general() -> NSMenu {
    let menu = NSMenu()
    menu.addItem(NSMenuItem(title: "Toggle \(appName)", action: #selector(AppDelegate.toggleKnobby(_:)), keyEquivalent: ""))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Settings", action: #selector(AppDelegate.orderFrontSettingsWindow), keyEquivalent: ","))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Quit \(appName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    return menu
  }
}
