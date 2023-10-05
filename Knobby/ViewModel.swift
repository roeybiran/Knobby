import Foundation

@Observable
final class ViewModel {
  let audioToolboxClient = AudioToolboxClient.liveValue
  let brightnessClient = BrightnessClient.liveValue
  
  let reservedKeys = Set<Character>(["h", "j", "k", "l"])

  private(set) var volumeValue = Float()
  private(set) var brightnessValue = Float()
  private(set) var focusedSlider: MainView.FocusedSlider?

  private func getCurrentValue() -> Float? {
    switch focusedSlider {
    case .brightness:
      brightnessValue
    case .volume:
      volumeValue
    case .none:
      nil
    }
  }

  private func setCurrentValue(_ newValue: Float) {
    switch focusedSlider {
    case .brightness:
      onBrightnessSliderChange(to: newValue)
    case .volume:
      onVolumeSliderChange(to: newValue)
    case .none:
      return
    }
  }

  private let sound = NSSound(named: "Blow")

  func onVolumeSliderChange(to value: Float) {
    audioToolboxClient.setVolume(value)
    sound?.stop()
    sound?.play()
    volumeValue = audioToolboxClient.getVolume()
  }

  func onBrightnessSliderChange(to value: Float) {
    brightnessClient.setBrightness(value)
    brightnessValue = brightnessClient.getBrightness()
  }

  func onAppear() {
    volumeValue = audioToolboxClient.getVolume()
    brightnessValue = brightnessClient.getBrightness()
  }

  func onFocusedSliderChanged(_ slider: MainView.FocusedSlider?) {
    focusedSlider = slider
  }

  func onKeyPress(_ char: Character) {
    guard let current = getCurrentValue() else { return }
    var newValue = current

    switch char {
    case "l":
      newValue += 0.1
    case "h":
      newValue -= 0.1
    case "j":
      newValue = 0
    case "k":
      newValue = 1
    default:
      break
    }

    setCurrentValue(max(newValue, 0))
  }
}
