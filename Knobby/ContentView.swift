import SwiftUI

struct ContentView: View {
  var viewModel: ViewModel
  @State private var knobbyShown = false

  func notchWidth() -> CGFloat {
    let left = NSScreen.main?.auxiliaryTopLeftArea?.width
    let right = NSScreen.main?.auxiliaryTopRightArea?.width
    let width = NSScreen.main?.visibleFrame.width
    if let left, let right, let width {
      return (width - left - right - 8)
    } else {
      return 0
    }
  }

  func notchHeight() -> CGFloat {
    if let height = NSScreen.main?.auxiliaryTopLeftArea?.height {
      return height
    } else {
      return 0
    }
  }

  //
  var body: some View {
    VStack {
      Spacer().frame(minHeight: notchHeight())
      VStack {
        CustomSlider(value: Double(viewModel.volumeValue), icon: "speaker.wave.2.fill", label: "Volume")
          .opacity(viewModel.focusedSlider == .volume ? 1 : 0.4)
          .frame(height: 8)
        CustomSlider(value: Double(viewModel.brightnessValue), icon: "sun.max.fill", label: "Brightness")
          .opacity(viewModel.focusedSlider == .brightness ? 1 : 0.4)
          .frame(height: 8)
      }
      .foregroundColor(.white)
      .opacity(knobbyShown ? 1 : 0)
      .animation(.easeInOut, value: viewModel.focusedSlider)
    }
    .padding()
    .frame(width: .knobbyWidth, height: .knobbyHeight)
    .background(UnevenRoundedRectangle(bottomLeadingRadius: 10, bottomTrailingRadius: 10).fill(.black))
    .scaleEffect(x: knobbyShown ? 1 : notchWidth() / .knobbyWidth, y: knobbyShown ? 1 : notchHeight() / .knobbyHeight, anchor: .top)
    .onChange(of: viewModel.isVisible) {
      withAnimation(.snappy) {
        knobbyShown = viewModel.isVisible
        if !viewModel.isVisible {
          NSApplication.shared.keyWindow?.resignKey()
          NSApplication.shared.keyWindow?.resignMain()
        }
      } completion: {
        if !viewModel.isVisible {
          NSApplication.shared.windows.first(where: { $0.identifier == .main })?.close()
        }
      }
    }
  }
}

// MARK: - ContentView_Previews
#Preview {
  ContentView(viewModel: .init())
}
