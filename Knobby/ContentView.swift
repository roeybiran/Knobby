import Carbon
import SwiftUI

struct ContentView: View {
  @Bindable var model: Model
  @FocusState private var focusedMetric: AdjustableMetric.Kind?

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      ForEach(model.values) { metric in
        VStack(alignment: .leading, spacing: 8) {
          Text(metric.deviceName)
            .font(.caption)
            .foregroundStyle(.secondary)

          HStack(spacing: 12) {
            Image(systemName: metric.imageName)
              .frame(width: 18)

            Slider(
              value: Binding(
                get: { Double(metric.currentValue) },
                set: { model.onSliderValueChanged(kind: metric.id, value: Float($0)) }
              ),
              in: 0...1
            )
            .controlSize(.extraLarge)
            .focused($focusedMetric, equals: metric.id)
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
    .onAppear {
      focusedMetric = model.focusedSetting
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
    .modifier(GlassBackgroundModifier())
  }
}

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
  return ContentView(model: model)
}
