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
        _ = DisplayServicesGetBrightness(displayID, &brightness)
        return brightness
      },
      setBrightness: { brightness in
        guard let displayID = getDisplayID() else { return }
        _ = DisplayServicesSetBrightness(displayID, brightness)
      }
    )
  }()
}

typealias CGDirectDisplayID = UInt32

@_silgen_name("DisplayServicesGetBrightness")
func DisplayServicesGetBrightness(
  _ display: CGDirectDisplayID,
  _ brightness: UnsafeMutablePointer<Float>
) -> Int32

@_silgen_name("DisplayServicesSetBrightness")
func DisplayServicesSetBrightness(
  _ display: CGDirectDisplayID,
  _ brightness: Float
) -> Int32
