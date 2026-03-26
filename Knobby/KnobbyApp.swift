import KeyboardShortcuts
import Observation
import SwiftUI

@main
struct KnobbyApp: App {
  @Environment(\.openSettings) private var openSettings
  @State private var hotKeyMonitor = HotKeyMonitor()
  @State private var isKnobbyPresented = true
  @State private var model = Model()

  var body: some Scene {
    Window(appName, id: "launcher") {
      Color.clear
        .frame(width: 1, height: 1)
        .allowsHitTesting(false)
        .floatingPanel(
          isPresented: $isKnobbyPresented,
          contentRect: CGRect(x: 0, y: 0, width: .knobbyWidth, height: 220)
        ) {
          ContentView(
            model: model,
            onOpenSettings: { openSettings() }
          )
        }
    }
    .defaultSize(width: 1, height: 1)
    .windowIdealPlacement { _, context in
      let bounds = context.defaultDisplay.bounds
      return WindowPlacement(
        x: bounds.minX - 100,
        y: bounds.minY - 100,
        width: 1,
        height: 1
      )
    }
    .windowResizability(.contentSize)
    .windowManagerRole(.associated)
    .windowStyle(.hiddenTitleBar)
    .onChange(of: hotKeyMonitor.toggleCount) {
      toggleKnobby()
    }

    MenuBarExtra {
      Button(
        isKnobbyPresented ? "Hide \(appName)" : "Show \(appName)",
        systemImage: isKnobbyPresented ? "eye.slash" : "eye"
      ) {
        toggleKnobby()
      }
      Divider()
      Button("Settings...", systemImage: "gearshape") {
        openSettings()
      }
      .keyboardShortcut(",", modifiers: .command)
    } label: {
      Label(appName, image: "MenuBarExtra")
        .labelStyle(.iconOnly)
    }
    .menuBarExtraStyle(.menu)

    Settings {
      SettingsView()
    }
    .commands {
      KnobbyCommands(
        model: model,
        onOpenSettings: { openSettings() }
      )
    }
  }

  private func toggleKnobby() {
    if isKnobbyPresented {
      isKnobbyPresented = false
    } else {
      model.refresh()
      isKnobbyPresented = true
    }
  }
}

@MainActor
@Observable
private final class HotKeyMonitor {
  var toggleCount = 0

  init() {
    KeyboardShortcuts.onKeyDown(for: .toggleKnobby) { [weak self] in
      Task { @MainActor in
        self?.toggleCount += 1
      }
    }
  }
}

private struct KnobbyCommands: Commands {
  let model: Model
  let onOpenSettings: () -> Void

  var body: some Commands {
    CommandMenu(appName) {
      Button("Decrease", systemImage: "minus") {
        model.onDecrease()
      }
      Button("Increase", systemImage: "plus") {
        model.onIncrease()
      }
      Button("Minimize", systemImage: "arrow.down.to.line") {
        model.onMinimize()
      }
      Button("Maximize", systemImage: "arrow.up.to.line") {
        model.onMaximize()
      }
      Divider()
      Button("Settings...", systemImage: "gearshape") {
        onOpenSettings()
      }
      .keyboardShortcut(",", modifiers: .command)
    }
  }
}
