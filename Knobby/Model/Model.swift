import Foundation
import Carbon
import SwiftUI

@Observable
final class Model {
  private(set) var values: [AdjustableMetric] = AdjustableMetric.allCases
  private(set) var focusedSetting = AdjustableMetric.allCases.first?.rawValue
  private(set) var isVisible = false

  func onIncrease() {
    guard let focusedSetting = focusedSetting else { return }
    values[focusedSetting].currentValue += 0.1
  }

  func onMaximize() {
    guard let focusedSetting = focusedSetting else { return }
    values[focusedSetting].currentValue = 1
  }

  func onMinimize() {
    guard let focusedSetting = focusedSetting else { return }
    values[focusedSetting].currentValue = .zero
  }

  func onDecrease() {
    guard let focusedSetting = focusedSetting else { return }
    values[focusedSetting].currentValue -= 0.1
  }

  func onSliderValueChanged(sender: Any?) {
    guard let slider = sender as? NSSlider else { return }
    let tag = slider.tag
    values[tag].currentValue = slider.floatValue
  }

  func onFocusedSliderChanged(change: NSKeyValueObservedChange<NSResponder?>) {
    guard let tag = change.newValue?.flatMap({ $0 as? NSSlider })?.tag else { return }
    focusedSetting = tag
  }

  func onToggleApp() {
    isVisible.toggle()

    if isVisible {
      values = AdjustableMetric.allCases
    }
  }

  func onEscapePress() {
    isVisible = false
  }

  func onResignKey() {
    isVisible = false
  }

  func notchHeight() -> CGFloat {
    NSScreen.main?.auxiliaryTopLeftArea?.height ?? .zero
  }

  private func notchWidth() -> CGFloat {
    let width = NSScreen.main?.visibleFrame.width ?? 0
    let left = NSScreen.main?.auxiliaryTopLeftArea?.width ?? 0
    let right = NSScreen.main?.auxiliaryTopRightArea?.width ?? 0
    return width - left - right
  }
}
