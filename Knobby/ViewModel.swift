import Foundation
import Carbon
import SwiftUI

@Observable
final class ViewModel {
  let audioToolboxClient = AudioToolboxClient.liveValue
  let brightnessClient = BrightnessClient.liveValue

  private(set) var volumeValue = Float()
  private(set) var brightnessValue = Float()
  private(set) var focusedSlider = FocusedSetting.volume
  private(set) var isVisible = false

  private func getCurrentValue() -> Float? {
    switch focusedSlider {
    case .brightness:
      brightnessValue
    case .volume:
      volumeValue
    }
  }

  private func setCurrentValue(_ newValue: Float) {
    switch focusedSlider {
    case .brightness:
      onBrightnessSliderChange(to: newValue)
    case .volume:
      onVolumeSliderChange(to: newValue)
    }
  }

  private func dismiss() {
    isVisible = false
    if let eventMonitor {
      NSEvent.removeMonitor(eventMonitor)
      self.eventMonitor = nil
    }
  }

  func onVolumeSliderChange(to value: Float) {
    audioToolboxClient.setVolume(value)
    volumeValue = audioToolboxClient.getVolume()
  }

  func onBrightnessSliderChange(to value: Float) {
    brightnessClient.setBrightness(value)
    brightnessValue = brightnessClient.getBrightness()
  }

  @ObservationIgnored
  var eventMonitor: Any?

  func onToggleApp() {
    if isVisible {
      dismiss()
    } else {
      isVisible = true
      volumeValue = audioToolboxClient.getVolume()
      brightnessValue = brightnessClient.getBrightness()
      eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
        guard let self else { return nil }
        let keyCode = event.keyCode
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
        case kVK_Tab:
          switch focusedSlider {
          case .volume:
            focusedSlider = .brightness
          case .brightness:
            focusedSlider = .volume
          }
          return nil
        case kVK_ANSI_Comma where event.modifierFlags.subtracting([.command]) == .init(rawValue: 264):
          (NSApplication.shared.delegate as? AppDelegate)?.orderFrontSettingsWindow(nil)
          return nil
        case kVK_Escape:
          dismiss()
          return nil
        default:
          return nil
        }

        setCurrentValue(max(newValue, 0))
        return nil
      }
    }
  }

  func onResignKey() {
    dismiss()
  }
}
