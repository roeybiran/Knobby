import AppKit
import Carbon
import SwiftUI

struct ContentView: View {
  @Bindable var model: Model
  let onToggle: () -> Void
  let onOpenSettings: () -> Void
  let onDismiss: () -> Void
  let onQuit: () -> Void
  @FocusState private var focusedMetric: AdjustableMetric.Kind?

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      HStack {
        Spacer()

        Menu {
          Button("Toggle \(appName)") {
            onToggle()
          }

          Divider()

          Button("Settings") {
            onOpenSettings()
          }
          .keyboardShortcut(",", modifiers: .command)

          Divider()

          Button("Quit \(appName)") {
            onQuit()
          }
          .keyboardShortcut("q", modifiers: .command)
        } label: {
          Image(nsImage: NSImage(named: NSImage.actionTemplateName) ?? .init())
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
      }

      ForEach(model.values) { metric in
        VStack(alignment: .leading, spacing: 8) {
          Text(metric.deviceName)
            .font(.caption)
            .foregroundStyle(.secondary)

          HStack(spacing: 12) {
            Image(systemName: metric.imageName)
              .frame(width: 18)

            let slider = Slider(
              value: Binding(
                get: { Double(metric.currentValue) },
                set: { model.onSliderValueChanged(kind: metric.id, value: Float($0)) }
              ),
              in: 0...1
            )
            .focused($focusedMetric, equals: metric.id)
            .disabled(!model.isVisible)
            .animation(.default, value: metric.currentValue)

            if #available(macOS 26.0, *) {
              slider.controlSize(.extraLarge)
            } else {
              slider.controlSize(.large)
            }
          }
        }
      }
    }
    .onChange(of: focusedMetric) { _, newValue in
      model.onFocusedMetricChanged(newValue)
    }
    .onChange(of: model.focusedSetting) { _, newValue in
      focusedMetric = newValue
    }
    .onChange(of: model.isVisible) { _, isVisible in
      guard isVisible else {
        focusedMetric = nil
        return
      }

      focusedMetric = nil
      DispatchQueue.main.async {
        focusedMetric = model.focusedSetting
      }
    }
    .onAppear {
      focusedMetric = model.focusedSetting
    }
    .onExitCommand {
      onDismiss()
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
    .padding(20)
    .frame(width: .knobbyWidth, alignment: .leading)
    .fixedSize(horizontal: false, vertical: true)
//    .modifier(GlassBackgroundModifier())
  }
}

private struct GlassBackgroundModifier: ViewModifier {
  func body(content: Content) -> some View {
    if #available(macOS 26.0, *) {
      content.glassEffect(.regular)
    } else {
      content
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
          RoundedRectangle(cornerRadius: 8)
            .stroke(.separator, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 6)
    }
  }
}

#Preview {
  let model = Model(
    audioToolboxClient: .init(
      outputDevices: {
        [
          .init(id: 1, name: "MacBook Speakers"),
          .init(id: 2, name: "Studio Display")
        ]
      },
      getVolume: { deviceID in
        switch deviceID {
        case 1:
          0.7
        default:
          0.4
        }
      },
      setVolume: { _, _ in }
    ),
    brightnessClient: .init(
      displays: {
        [
          .init(id: 11, name: "Built-in Display"),
          .init(id: 12, name: "LG UltraFine")
        ]
      },
      getBrightness: { displayID in
        switch displayID {
        case 11:
          0.8
        default:
          0.55
        }
      },
      setBrightness: { _, _ in }
    )
  )
  model.isVisible = true
  return ContentView(
    model: model,
    onToggle: {},
    onOpenSettings: {},
    onDismiss: {},
    onQuit: {}
  )
}
