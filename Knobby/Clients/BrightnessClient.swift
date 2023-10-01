import Foundation

// https://stackoverflow.com/questions/32691397/adjust-screen-brightness-in-mac-os-x-app
// https://stackoverflow.com/questions/3239749/programmatically-change-mac-display-brightness
// https://github.com/carabina/BrightnessMenu/tree/master

struct BrightnessClient {
  var getBrightness: () -> Float
  var setBrightness: (_ value: Float) -> Void

  static let liveValue: Self = {
    func connect() -> (iterator: io_iterator_t, service: io_object_t) {
      var iterator: io_iterator_t = 0
      let result = IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("IODisplayConnect"), &iterator)
      if result != kIOReturnSuccess {
        print(String(format:"%02X", result), #file, #line)
      }
      var service: io_object_t = 1
      return (iterator, service)
    }

    return Self(
      getBrightness: {
        var (iterator, service) = connect()
        var brightness: float_t = 0.5
        while service != 0 {
          service = IOIteratorNext(iterator)
          let result = IODisplayGetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, &brightness)
          // https://github.com/apple-oss-distributions/xnu/blob/fdd8201d7b966f0c3ea610489d29bd841d358941/iokit/IOKit/IOReturn.h#L153
          if result != kIOReturnSuccess {
            print(String(format:"%02X", result), #file, #line)
          }
          IOObjectRelease(service)
        }

        return brightness
      },
      setBrightness: { brightness in
        var (iterator, service) = connect()
        while service != 0 {
          service = IOIteratorNext(iterator)
          let result = IODisplaySetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, brightness)
          if result != kIOReturnSuccess {
            print(String(format:"%02X", result), #file, #line)
          }
          IOObjectRelease(service)
        }
      }
    )
  }()
}
