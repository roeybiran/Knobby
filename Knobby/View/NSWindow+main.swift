extension NSWindow {
  static let main: Panel = {
    let panel = Panel()
    panel.hidesOnDeactivate = false
    panel.identifier = .mainWindow
    panel.level = .screenSaver
    panel.title = appName
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
}
