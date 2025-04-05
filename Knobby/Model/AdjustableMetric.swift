enum AdjustableMetric: Int, CaseIterable {
  case volume
  case brightness

  static let audioToolboxClient = AudioToolboxClient.liveValue
  static let brightnessClient = BrightnessClient.liveValue

  var imageName: String {
    switch self {
    case .volume:
      "speaker.wave.2.fill"
    case .brightness:
      "sun.max.fill"
    }
  }

  var currentValue: Float {
    get {
      switch self {
      case .volume:
        Self.audioToolboxClient.getVolume()
      case .brightness:
        Self.brightnessClient.getBrightness()
      }
    }
    set {
      switch self {
      case .volume:
        Self.audioToolboxClient.setVolume(newValue)
      case .brightness:
        Self.brightnessClient.setBrightness(newValue)
      }
    }
  }
}
