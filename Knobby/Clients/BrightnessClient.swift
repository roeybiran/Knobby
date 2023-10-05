import Foundation
import Cocoa

struct BrightnessClient {
  var getBrightness: () -> Float
  var setBrightness: (_ value: Float) -> Void

  static let liveValue: Self = {
    func getDisplayID() -> CGDirectDisplayID? {
      NSScreen.main?.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID
    }

    return Self(
      getBrightness: {
        var brightness: Float = 0
        guard let displayID = getDisplayID() else { return brightness }
        DisplayServicesGetBrightness(displayID, &brightness)
        return brightness
      },
      setBrightness: { brightness in
        guard let displayID = getDisplayID() else { return }
        DisplayServicesSetBrightness(displayID, brightness)
      }
    )
  }()
}

