import SwiftUI

struct CustomSlider: View {
  var value = 0.0
  var icon: String = "speaker.wave.2.fill"
  var label: String = "Volume"

  var body: some View {
    HStack {
      Image(systemName: icon)
        .frame(width: 24)
        .accessibilityLabel(label)
      Rectangle()
        .fill(.gray)
        .overlay {
          GeometryReader { proxy in
            Rectangle()
              .fill(.white)
              .frame(width: proxy.size.width * value)
          }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    .animation(.spring, value: value)
    .transition(.opacity.combined(with: .slide).combined(with: .symbolEffect))

  }
}

#Preview {
  CustomSlider()
}
