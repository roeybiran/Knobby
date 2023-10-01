import Foundation

final class ViewModel: ObservableObject {
  let audioToolboxClient = AudioToolboxClient.liveValue
  let brightnessClient = BrightnessClient.liveValue

  @Published var volumeValue = Float()
  @Published var brightnessValue = Float()

  func volumeChanged(to value: Float) {
    audioToolboxClient.setVolume(value)
    volumeValue = audioToolboxClient.getVolume()
  }

  func brightnessChanged(to value: Float) {
    brightnessClient.setBrightness(value)
    brightnessValue = brightnessClient.getBrightness()
  }

  func onAppear() {
    volumeValue = audioToolboxClient.getVolume()
    brightnessValue = brightnessClient.getBrightness()
  }
}
