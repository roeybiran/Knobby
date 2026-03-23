import Testing
@testable import Knobby

@MainActor
struct `Model Tests` {
  @Test
  func `onToggleApp, should rebuild controls in output then display order`() {
    let model = Model(
      audioToolboxClient: .init(
        outputDevices: {
          [
            .init(id: 3, name: "MacBook Speakers"),
            .init(id: 7, name: "Studio Display")
          ]
        },
        getVolume: { deviceID in
          switch deviceID {
          case 3:
            0.8
          default:
            0.4
          }
        },
        setVolume: { _, _ in }
      ),
      brightnessClient: .init(
        displays: {
          [
            .init(id: 11, name: "Built-in Display"),
            .init(id: 12, name: "LG UltraFine")
          ]
        },
        getBrightness: { displayID in
          switch displayID {
          case 11:
            0.75
          default:
            0.5
          }
        },
        setBrightness: { _, _ in }
      )
    )

    model.onToggleApp()

    #expect(model.isVisible)
    #expect(model.focusedSetting == .outputDevice(3))
    #expect(
      model.values == [
        .init(kind: .outputDevice(3), deviceName: "MacBook Speakers", currentValue: 0.8),
        .init(kind: .outputDevice(7), deviceName: "Studio Display", currentValue: 0.4),
        .init(kind: .displayDevice(11), deviceName: "Built-in Display", currentValue: 0.75),
        .init(kind: .displayDevice(12), deviceName: "LG UltraFine", currentValue: 0.5),
      ]
    )
  }

  @Test
  func `onIncrease, onDecrease, onMaximize and onMinimize, should update the focused output device`() {
    var outputVolume = Float(0.4)
    let model = Model(
      audioToolboxClient: .init(
        outputDevices: { [.init(id: 1, name: "MacBook Speakers")] },
        getVolume: { _ in outputVolume },
        setVolume: { _, volume in
          outputVolume = volume
        }
      ),
      brightnessClient: .init(
        displays: { [] },
        getBrightness: { _ in .zero },
        setBrightness: { _, _ in }
      )
    )

    model.onToggleApp()

    model.onIncrease()
    #expect(abs(model.values[0].currentValue - 0.5) < 0.0001)
    #expect(abs(outputVolume - 0.5) < 0.0001)

    model.onDecrease()
    #expect(abs(model.values[0].currentValue - 0.4) < 0.0001)
    #expect(abs(outputVolume - 0.4) < 0.0001)

    model.onMaximize()
    #expect(model.values[0].currentValue == 1)
    #expect(outputVolume == 1)

    model.onMinimize()
    #expect(model.values[0].currentValue == 0)
    #expect(outputVolume == 0)
  }

  @Test
  func `onSliderValueChanged, should update the selected display brightness`() {
    var brightness = Float(0.3)
    let model = Model(
      audioToolboxClient: .init(
        outputDevices: { [] },
        getVolume: { _ in .zero },
        setVolume: { _, _ in }
      ),
      brightnessClient: .init(
        displays: { [.init(id: 11, name: "Built-in Display")] },
        getBrightness: { _ in brightness },
        setBrightness: { _, value in
          brightness = value
        }
      )
    )

    model.onToggleApp()
    model.onSliderValueChanged(kind: .displayDevice(11), value: 0.9)

    #expect(abs(model.values[0].currentValue - 0.9) < 0.0001)
    #expect(abs(brightness - 0.9) < 0.0001)
  }

  @Test
  func `onToggleApp, when focused device disappears, should focus the first available control`() {
    let outputDevices = [
      AudioToolboxClient.Device(id: 1, name: "MacBook Speakers"),
      AudioToolboxClient.Device(id: 2, name: "Headphones"),
    ]
    var outputVolumes: [UInt32: Float] = [
      1: 0.6,
      2: 0.4,
    ]
    var displays = [BrightnessClient.Display(id: 11, name: "Built-in Display")]
    var brightnessValues: [UInt32: Float] = [11: 0.75]

    let model = Model(
      audioToolboxClient: .init(
        outputDevices: { outputDevices },
        getVolume: { deviceID in outputVolumes[deviceID] ?? .zero },
        setVolume: { deviceID, volume in
          outputVolumes[deviceID] = volume
        }
      ),
      brightnessClient: .init(
        displays: { displays },
        getBrightness: { displayID in brightnessValues[displayID] ?? .zero },
        setBrightness: { displayID, value in
          brightnessValues[displayID] = value
        }
      )
    )

    model.onToggleApp()
    model.onFocusedMetricChanged(.displayDevice(11))
    model.onToggleApp()

    displays = []
    model.onToggleApp()

    #expect(model.focusedSetting == .outputDevice(1))
  }
}
