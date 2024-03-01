import SwiftUI
import ServiceManagement

// MARK: - ContentView

struct ContentView: View {
  @Bindable var viewModel: ViewModel
  @FocusState private var focusedField: FocusedSlider?
  @State private var isPopoverShown = false
  let statusItem: NSStatusItem

  enum FocusedSlider: Equatable {
    case volume
    case brightness
  }

  var body: some View {
    ZStack {
      VisualEffectView()
      Form {
        Slider(
          value: .init(
            get: { viewModel.volumeValue },
            set: { viewModel.onVolumeSliderChange(to: $0) }
          ), in: 0...1, step: 0.1) {
            Image(systemName: "speaker.wave.3.fill")
              .accessibilityLabel("Volume")
          }
          .focused($focusedField, equals: .volume)
        Slider(
          value: .init(
            get: { viewModel.brightnessValue },
            set: { viewModel.onBrightnessSliderChange(to: $0) }
          ), in: 0...1, step: 0.1) {
            Image(systemName: "sun.max.fill")
              .accessibilityLabel("Brightness")
          }
          .focused($focusedField, equals: .brightness)

        Button {
          isPopoverShown.toggle()
        } label: {
          Image(systemName: "gear")
        }
        .buttonStyle(.borderless)
        .popover(isPresented: $isPopoverShown, arrowEdge: .bottom) {
          Form {
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
          }.formStyle(.grouped)
        }
      }
      .foregroundColor(.gray)
      .onKeyPress { _ in
        guard let keycode = NSApplication.shared.currentEvent?.keyCode else { return .ignored }
        return viewModel.onKeyPress(keycode)
      }
      .onAppear {
        viewModel.onAppear()
        focusedField = .volume
      }
      .onChange(of: focusedField) {
        viewModel.onFocusedSliderChanged($1)
      }
      .formStyle(.grouped)
    }
    .frame(width: 480, height: 160)
    .clipShape(.rect(cornerRadius: 8, style: .circular))
    .offset(x: 0, y: viewModel.isVisible ? 0 : -160)
    .animation(.bouncy, value: viewModel.isVisible)
  }
}

// MARK: - ContentView_Previews
#Preview {
  ContentView(viewModel: .init(), statusItem: .init())
}

