import Foundation
import Observation

@MainActor
@Observable
final class Model {

  // MARK: Lifecycle

  init(
    audioToolboxClient: AudioToolboxClient = .liveValue,
    brightnessClient: BrightnessClient = .liveValue,
  ) {
    self.audioToolboxClient = audioToolboxClient
    self.brightnessClient = brightnessClient
    values = Self.makeValues(
      audioToolboxClient: audioToolboxClient,
      brightnessClient: brightnessClient,
    )
    stopObservingOutputDevices = audioToolboxClient.observeOutputDevices { [weak self] in
      Task { @MainActor in
        self?.refresh()
      }
    }
    stopObservingDisplays = brightnessClient.observeDisplays { [weak self] in
      Task { @MainActor in
        self?.refresh()
      }
    }
  }

  isolated deinit {
    stopObservingOutputDevices()
    stopObservingDisplays()
  }

  // MARK: Internal

  private(set) var values: [AdjustableMetric]

  func increase(_ kind: AdjustableMetric.Kind) {
    guard let index = values.firstIndex(where: { $0.id == kind }) else { return }
    applyValue(values[index].currentValue + 0.1, at: index)
  }

  func maximize(_ kind: AdjustableMetric.Kind) {
    guard let index = values.firstIndex(where: { $0.id == kind }) else { return }
    applyValue(1, at: index)
  }

  func minimize(_ kind: AdjustableMetric.Kind) {
    guard let index = values.firstIndex(where: { $0.id == kind }) else { return }
    applyValue(.zero, at: index)
  }

  func decrease(_ kind: AdjustableMetric.Kind) {
    guard let index = values.firstIndex(where: { $0.id == kind }) else { return }
    applyValue(values[index].currentValue - 0.1, at: index)
  }

  func setValue(kind: AdjustableMetric.Kind, value: Float) {
    guard let index = values.firstIndex(where: { $0.id == kind }) else { return }
    applyValue(value, at: index)
  }

  func refresh() {
    values = Self.makeValues(
      audioToolboxClient: audioToolboxClient,
      brightnessClient: brightnessClient,
    )
  }

  // MARK: Private

  private let audioToolboxClient: AudioToolboxClient
  private let brightnessClient: BrightnessClient
  private var stopObservingOutputDevices: () -> Void = {}
  private var stopObservingDisplays: () -> Void = {}

  private static func makeValues(
    audioToolboxClient: AudioToolboxClient,
    brightnessClient: BrightnessClient,
  ) -> [AdjustableMetric] {
    let outputMetrics = audioToolboxClient.outputDevices().map { device in
      AdjustableMetric(
        kind: .outputDevice(device.id),
        deviceName: device.name,
        currentValue: audioToolboxClient.getVolume(device.id),
      )
    }
    let displayMetrics = brightnessClient.displays().map { display in
      AdjustableMetric(
        kind: .displayDevice(display.id),
        deviceName: display.name,
        currentValue: brightnessClient.getBrightness(display.id),
      )
    }
    return outputMetrics + displayMetrics
  }

  private func applyValue(_ value: Float, at index: Int) {
    let clampedValue = max(0, min(1, value))
    values[index].currentValue = clampedValue

    switch values[index].kind {
    case .outputDevice(let deviceID):
      audioToolboxClient.setVolume(deviceID, clampedValue)
    case .displayDevice(let displayID):
      brightnessClient.setBrightness(displayID, clampedValue)
    }
  }

}
