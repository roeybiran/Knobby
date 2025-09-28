import Foundation
import KeyboardShortcuts

let appName = "Knobby"

extension CGFloat {
  static let knobbyWidth = Self(300)
}

extension NSUserInterfaceItemIdentifier {
  static let mainWindow = Self("MainWindow")
}

extension NSWindow.FrameAutosaveName {
  static let settingsWindow = Self("MainWindow")
}

extension KeyboardShortcuts.Name {
  static let toggleKnobby = Self("toggleKnobby")
}
