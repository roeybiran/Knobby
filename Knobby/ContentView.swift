import SwiftUI

struct ContentView: View {
  @Environment(\.floatingPanel) private var floatingPanel
  @Bindable var model: Model
  let onOpenSettings: () -> Void
  @FocusState private var focusedMetric: AdjustableMetric.Kind?

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      ForEach(model.values) { metric in
        VStack(alignment: .leading, spacing: 4) {
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
            .animation(.default, value: metric.currentValue)

            if #available(macOS 26.0, *) {
              slider.controlSize(.extraLarge)
            } else {
              slider.controlSize(.large)
            }
          }
        }
        Divider()
      }
    }
    .padding()
    .toolbar {
      ToolbarItem {
        Menu {
          Button("Refresh", systemImage: "arrow.clockwise") {
            model.refresh()
          }
          Divider()
          Button("Settings...", systemImage: "gearshape") {
            onOpenSettings()
          }
        } label: {
          Image(systemName: "ellipsis.circle")
        }
      }
    }
    .onChange(of: focusedMetric) { _, newValue in
      model.onFocusedMetricChanged(newValue)
    }
    .onChange(of: model.focusedSetting) { _, newValue in
      focusedMetric = newValue
    }
    .onAppear {
      model.refresh()
      focusedMetric = model.focusedSetting
    }
    .onExitCommand {
      floatingPanel?.close()
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
    .frame(width: .knobbyWidth, alignment: .leading)
    .glassEffect()
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
  return ContentView(
    model: model,
    onOpenSettings: {}
  )
}
