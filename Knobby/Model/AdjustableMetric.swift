import AudioToolbox
import Foundation

struct AdjustableMetric: Identifiable, Hashable {
  enum Kind: Hashable {
    case outputDevice(AudioDeviceID)
    case displayDevice(CGDirectDisplayID)
  }

  let kind: Kind
  let deviceName: String
  var currentValue: Float
  var isMuted = false

  var id: Kind {
    kind
  }

  var imageName: String {
    switch kind {
    case .outputDevice:
      isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"
    case .displayDevice:
      "sun.max.fill"
    }
  }
}
