import SwiftUI

  // MARK: - ContentView

struct MainView: View {
  @Bindable var viewModel: ViewModel
  @FocusState private var focusedField: FocusedSlider?

  enum FocusedSlider: Equatable {
    case volume, brightness
  }

  var body: some View {
    Spacer()
    Form {
      Slider(
        value: .init(
          get: { viewModel.volumeValue },
          set: { viewModel.onVolumeSliderChange(to: $0) }
        ), in: 0...1, step: 0.1) {
          Image(systemName: "speaker.wave.3.fill")
        }
        .focused($focusedField, equals: .volume)
      Slider(
        value: .init(
          get: { viewModel.brightnessValue },
          set: { viewModel.onBrightnessSliderChange(to: $0) }
        ), in: 0...1, step: 0.1) {
        Image(systemName: "sun.max.fill")
      }
      .focused($focusedField, equals: .brightness)
    }
    .formStyle(.grouped)
    .onKeyPress(action: { press in
      guard let keycode = NSApplication.shared.currentEvent?.keyCode else { return .ignored }
      if KeyCode(rawValue: keycode) != nil {
        viewModel.onKeyPress(keycode)
        return .handled
      } else {
        return .ignored
      }
    })
    .onAppear(perform: viewModel.onAppear)
    .onChange(of: focusedField, { oldValue, newValue in
      viewModel.onFocusedSliderChanged(newValue)
    })
    Spacer()
  }
}

  // MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    MainView(viewModel: .init())
  }
}
