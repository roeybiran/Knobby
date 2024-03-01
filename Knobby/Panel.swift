import Cocoa

final class Panel: NSPanel {
  override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
    super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
    hidesOnDeactivate = false
    level = .floating
    title = "Knobby"
    styleMask = [.closable, .borderless, .nonactivatingPanel]
    hasShadow = false
    backgroundColor = .clear
    titlebarAppearsTransparent = true
    titleVisibility = .hidden
    standardWindowButton(.closeButton)?.isHidden = true
    standardWindowButton(.miniaturizeButton)?.isHidden = true
    standardWindowButton(.zoomButton)?.isHidden = true
    isFloatingPanel = true
    becomesKeyOnlyIfNeeded = false
  }

  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { true }
}
