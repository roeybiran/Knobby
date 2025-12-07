import Cocoa

extension NSWindow {
  static let settings: NSWindow = {
    let window = NSWindow(
      contentRect: .init(origin: .zero, size: .zero),
      styleMask: [.closable, .titled],
      backing: .buffered,
      defer: true
    )
    window.setFrameAutosaveName(.settingsWindow)
    window.isReleasedWhenClosed = false
    window.title = "\(appName) Settings"
    return window
  }()
}
