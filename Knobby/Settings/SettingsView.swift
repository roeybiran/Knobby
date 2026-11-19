import KeyboardShortcuts
import ServiceManagement
import SwiftUI

struct SettingsView: View {

  // MARK: Lifecycle

  init(statusItem: NSStatusItem) {
    self.statusItem = statusItem
    _launchesAtLogin = State(initialValue: SMAppService.mainApp.status == .enabled)
    _showsMenuBarExtra = State(initialValue: statusItem.isVisible)
  }

  // MARK: Internal

  let statusItem: NSStatusItem

  var body: some View {
    Form {
      Toggle("Launch at Login", isOn: Binding(
        get: { launchesAtLogin },
        set: { setLaunchesAtLogin($0) },
      ))
      Toggle("Show Menu Bar Extra", isOn: Binding(
        get: { showsMenuBarExtra },
        set: { isOn in
          statusItem.isVisible = isOn
          showsMenuBarExtra = statusItem.isVisible
        },
      ))
      KeyboardShortcuts.Recorder("Keyboard Shortcut", name: .toggleKnobby)
    }
    .formStyle(.grouped)
    // Both settings can change behind our back: the login item in System Settings,
    // the menu bar extra by dragging it out of the menu bar.
    .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in
      syncWithSystem()
    }
    .alert(
      "Couldn’t Change Launch at Login",
      isPresented: Binding(
        get: { launchAtLoginError != nil },
        set: { if !$0 { launchAtLoginError = nil } },
      ),
    ) {
      Button("OK") {}
    } message: {
      Text(launchAtLoginError ?? "")
    }
  }

  // MARK: Private

  @State private var launchesAtLogin: Bool
  @State private var showsMenuBarExtra: Bool
  @State private var launchAtLoginError: String?

  private func setLaunchesAtLogin(_ isOn: Bool) {
    do {
      if isOn {
        try SMAppService.mainApp.register()
      } else {
        try SMAppService.mainApp.unregister()
      }
    } catch {
      launchAtLoginError = error.localizedDescription
    }
    launchesAtLogin = SMAppService.mainApp.status == .enabled
  }

  private func syncWithSystem() {
    launchesAtLogin = SMAppService.mainApp.status == .enabled
    showsMenuBarExtra = statusItem.isVisible
  }

}

#Preview {
  SettingsView(statusItem: .init())
}
