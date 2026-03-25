import AppKit
import Foundation

struct BrightnessClient {
  struct Display: Identifiable, Hashable {
    let id: CGDirectDisplayID
    let name: String
  }

  var displays: () -> [Display]
  var getBrightness: (_ displayID: CGDirectDisplayID) -> Float
  var setBrightness: (_ displayID: CGDirectDisplayID, _ value: Float) -> Void

  static let liveValue: Self = {
    return Self(
      displays: {
        NSScreen.screens.compactMap { screen in
          guard
            let displayID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID
          else { return nil }

          var brightness = Float.zero
          guard DisplayServicesGetBrightness(displayID, &brightness) == 0 else { return nil }
          return Display(id: displayID, name: screen.localizedName)
        }
      },
      getBrightness: { displayID in
        var brightness = Float.zero
        guard DisplayServicesGetBrightness(displayID, &brightness) == 0 else { return .zero }
        return brightness
      },
      setBrightness: { displayID, value in
        _ = DisplayServicesSetBrightness(displayID, max(0, min(1, value)))
      }
    )
  }()
}
