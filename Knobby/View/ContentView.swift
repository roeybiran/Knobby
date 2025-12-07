import SwiftUI
import Carbon

struct ContentView: View {
  @Bindable var model: Model
  @FocusState private var focusedMetric: AdjustableMetric?

  var body: some View {
    VStack(spacing: 8) {
      ForEach(model.values.enumerated(), id: \.element) { (offset, metric) in
        HStack {
          Image(systemName: metric.imageName)
          Slider(
            value: Binding(
              get: { model.values[offset].currentValue },
              set: { model.values[offset].currentValue = $0 }
            ),
            in: 0...1
          )
          .controlSize(.extraLarge)
        }
        .focused($focusedMetric, equals: metric)
      }
    }
//    .scaleEffect(model.isVisible ? 1 : 0, anchor: .top)
//    .animation(.spring(duration: 0.3, bounce: 0.3), value: model.isVisible)
    .onChange(of: focusedMetric) { _, newValue in
      model.focusedSetting = newValue?.rawValue
    }
    .onAppear {
      focusedMetric = model.values.first
    }
    .onKeyPress { press in
      switch press.key {
      case "h":
        model.onDecrease()
        return .handled
      case "j":
        model.onMinimize()
        return .handled
      case "k":
        model.onMaximize()
        return .handled
      case "l":
        model.onIncrease()
        return .handled
      default:
        return .ignored
      }
    }
    .padding()
    .frame(width: .knobbyWidth)
    .modifier(GlassBackgroundModifier())
//    .shadow(radius: 2)
  }
}

// MARK: - Menu Button

//private struct MenuButton: View {
//  var body: some View {
//    Menu {
//      Button("Settings...") {
//        NSApp.sendAction(Selector(("orderFrontSettingsWindow")), to: nil, from: nil)
//      }
//      .keyboardShortcut(",", modifiers: .command)
//
//      Divider()
//
//      Button("Quit \(appName)") {
//        NSApplication.shared.terminate(nil)
//      }
//      .keyboardShortcut("q", modifiers: .command)
//    } label: {
//      Image(systemName: "gearshape")
//        .foregroundStyle(.secondary)
//    }
//    .menuStyle(.borderlessButton)
//    .menuIndicator(.hidden)
//    .fixedSize()
//  }
//}

// MARK: - Glass Background Modifier

private struct GlassBackgroundModifier: ViewModifier {
  func body(content: Content) -> some View {
    if #available(macOS 26.0, *) {
      content.glassEffect(.regular)
    } else {
      content
    }
  }
}

#Preview {
  let model = Model()
  model.isVisible = true
  return ContentView(model: model)
}
