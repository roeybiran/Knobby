import Foundation
import Carbon
import SwiftUI

@Observable
final class ViewModel {
  let audioToolboxClient = AudioToolboxClient.liveValue
  let brightnessClient = BrightnessClient.liveValue

  private(set) var volumeValue = Float()
  private(set) var brightnessValue = Float()
  private(set) var focusedSlider: ContentView.FocusedSlider?
  private(set) var isVisible = false

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

  private func dismiss() {
    isVisible = false
  }

  func onVolumeSliderChange(to value: Float) {
    audioToolboxClient.setVolume(value)
    volumeValue = audioToolboxClient.getVolume()
  }

  func onBrightnessSliderChange(to value: Float) {
    brightnessClient.setBrightness(value)
    brightnessValue = brightnessClient.getBrightness()
  }

  func onFocusedSliderChanged(_ slider: ContentView.FocusedSlider?) {
    focusedSlider = slider
  }

  func onToggleApp() {
    if isVisible {
      dismiss()
    } else {
      isVisible = true
      volumeValue = audioToolboxClient.getVolume()
      brightnessValue = brightnessClient.getBrightness()
    }
  }

  func onResignKey() {
    dismiss()
  }

  func onKeyPress(_ keyCode: UInt16) -> KeyPress.Result {
    var newValue = getCurrentValue() ?? 0
    switch Int(keyCode) {
    case kVK_ANSI_L:
      newValue += 0.1
    case kVK_ANSI_H:
      newValue -= 0.1
    case kVK_ANSI_J:
      newValue = 0
    case kVK_ANSI_K:
      newValue = 1
    case kVK_Escape:
      dismiss()
      return .handled
    default:
      return .ignored
    }

    setCurrentValue(max(newValue, 0))
    return .handled
  }
}
