import SwiftUI

// MARK: - ContentView

struct MainView: View {
  @ObservedObject var viewModel: ViewModel
  @State var monitor: Any?
  @State private var volumeValue = 0.0
  @State private var brightnessValue = 0.0
  @FocusState var focusedField: FocusedField?

  enum FocusedField: Equatable {
    case volume, brightness
  }

  func getCurrentValue() -> Double? {
    switch focusedField {
    case .brightness:
      brightnessValue
    case .volume:
       volumeValue
    case .none:
      nil
    }
  }

  func settCurrentValue(_ newValue: Double) {
    switch focusedField {
    case .brightness:
      brightnessValue = newValue
    case .volume:
      volumeValue = newValue
    case .none:
      return
    }
  }

  var body: some View {
    Form {
      Slider(value: $volumeValue, in: 0...1, step: 0.1) {
        Text("Volume")
      }
      .focused($focusedField, equals: .volume)
      Slider(value: $brightnessValue, in: 0...1, step: 0.1) {
        Text("Brightness")
      }
      .focused($focusedField, equals: .brightness)
    }
    .formStyle(.grouped)
    .onAppear {
      viewModel.onAppear()
      volumeValue = Double(viewModel.volumeValue)
      brightnessValue = Double(viewModel.brightnessValue)

      monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
        guard let current = getCurrentValue() else { return event }
        var newValue = current

        switch event.keyCode {
        case 37: // l
          newValue += 0.1
        case 4: // h
          newValue -= 0.1
        case 38: // j
          newValue = 0
        case 40: // k
          newValue = 1
        default:
          break
        }

        settCurrentValue(max(newValue, 0))
        return event
      }
    }
    .onChange(of: brightnessValue, perform: { value in
      viewModel.brightnessChanged(to: Float(value))
    })
    .onChange(of: volumeValue, perform: { value in
      viewModel.volumeChanged(to: Float(value))
    })
    .onDisappear {
      if let monitor {
        NSEvent.removeMonitor(monitor)
      }
    }
  }
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    MainView(viewModel: .init())
  }
}
