import Foundation
import Observation

@MainActor
@Observable
final class Model {
  var values: [AdjustableMetric]
  var focusedSetting: AdjustableMetric.Kind?

  @ObservationIgnored private let audioToolboxClient: AudioToolboxClient
  @ObservationIgnored private let brightnessClient: BrightnessClient

  init(
    audioToolboxClient: AudioToolboxClient = .liveValue,
    brightnessClient: BrightnessClient = .liveValue
  ) {
    self.audioToolboxClient = audioToolboxClient
    self.brightnessClient = brightnessClient
    self.values = Self.makeValues(
      audioToolboxClient: audioToolboxClient,
      brightnessClient: brightnessClient
    )
    self.focusedSetting = self.values.first?.id
  }

  func refresh() {
    let previouslyFocusedSetting = focusedSetting
    values = Self.makeValues(
      audioToolboxClient: audioToolboxClient,
      brightnessClient: brightnessClient
    )

    if let previouslyFocusedSetting, values.contains(where: { $0.id == previouslyFocusedSetting }) {
      focusedSetting = previouslyFocusedSetting
    } else {
      focusedSetting = values.first?.id
    }
  }

  func onIncrease() {
    guard let index = indexForFocusedSetting() else { return }
    applyValue(values[index].currentValue + 0.1, at: index)
  }

  func onMaximize() {
    guard let index = indexForFocusedSetting() else { return }
    applyValue(1, at: index)
  }

  func onMinimize() {
    guard let index = indexForFocusedSetting() else { return }
    applyValue(.zero, at: index)
  }

  func onDecrease() {
    guard let index = indexForFocusedSetting() else { return }
    applyValue(values[index].currentValue - 0.1, at: index)
  }

  func onSliderValueChanged(kind: AdjustableMetric.Kind, value: Float) {
    guard let index = values.firstIndex(where: { $0.id == kind }) else { return }
    applyValue(value, at: index)
  }

  func onFocusedMetricChanged(_ kind: AdjustableMetric.Kind?) {
    focusedSetting = kind
  }

  private func indexForFocusedSetting() -> Int? {
    guard let focusedSetting else { return nil }
    return values.firstIndex(where: { $0.id == focusedSetting })
  }

  private func applyValue(_ value: Float, at index: Int) {
    let clampedValue = max(0, min(1, value))
    values[index].currentValue = clampedValue

    switch values[index].kind {
    case let .outputDevice(deviceID):
      audioToolboxClient.setVolume(deviceID, clampedValue)
    case let .displayDevice(displayID):
      brightnessClient.setBrightness(displayID, clampedValue)
    }
  }

  private static func makeValues(
    audioToolboxClient: AudioToolboxClient,
    brightnessClient: BrightnessClient
  ) -> [AdjustableMetric] {
    let outputMetrics = audioToolboxClient.outputDevices().map { device in
      AdjustableMetric(
        kind: .outputDevice(device.id),
        deviceName: device.name,
        currentValue: audioToolboxClient.getVolume(device.id)
      )
    }
    let displayMetrics = brightnessClient.displays().map { display in
      AdjustableMetric(
        kind: .displayDevice(display.id),
        deviceName: display.name,
        currentValue: brightnessClient.getBrightness(display.id)
      )
    }
    return outputMetrics + displayMetrics
  }
}
