import Foundation
import Cocoa

struct BrightnessClient {
  var getBrightness: () -> Float
  var setBrightness: (_ value: Float) -> Void

  // as of macOS Sonoma and on Apple Silicon, the only reliable way to programmatically control the display’s brightness is through the private DisplayServices framework.
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

