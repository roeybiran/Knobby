import SwiftUI
import ServiceManagement
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
  static let toggleKnobby = Self("toggleKnobby")
}
struct SettingsView: View {
  let statusItem: NSStatusItem

  var body: some View {
    Form {
      KeyboardShortcuts.Recorder("Keyboard Shortcut", name: .toggleKnobby)
      Toggle("Launch at Login", isOn: Binding(get: {
        SMAppService.mainApp.status == .enabled
      }, set: { isOn in
        try? isOn ? SMAppService.mainApp.register() : SMAppService.mainApp.unregister()
      }))
      Toggle("Show Menu Bar Extra", isOn: Binding(get: {
        statusItem.isVisible
      }, set: { isOn in
        statusItem.isVisible = isOn
      }))
    }
    .formStyle(.grouped)
  }


}

#Preview {
  SettingsView(statusItem: .init())
}
