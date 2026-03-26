import KeyboardShortcuts
import ServiceManagement
import SwiftUI

struct SettingsView: View {
  var body: some View {
    Form {
      Toggle(
        "Launch at Login",
        isOn: Binding(
          get: { SMAppService.mainApp.status == .enabled },
          set: { isOn in
            try? isOn ? SMAppService.mainApp.register() : SMAppService.mainApp.unregister()
          }
        )
      )
      KeyboardShortcuts.Recorder("Keyboard Shortcut", name: .toggleKnobby)
    }
    .formStyle(.grouped)
  }
}

#Preview {
  SettingsView()
}
