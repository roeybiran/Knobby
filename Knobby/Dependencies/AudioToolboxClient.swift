import AudioToolbox
import Foundation

// https://github.com/Hammerspoon/hammerspoon/blob/56b5835dc1bf7bb430dfea3f1662379cccec0c82/extensions/audiodevice/libaudiodevice.m#L253
// https://github.com/Hammerspoon/hammerspoon/blob/56b5835dc1bf7bb430dfea3f1662379cccec0c82/extensions/audiodevice/libaudiodevice.m#L1013

struct AudioToolboxClient {
  var getVolume: () -> Float
  var setVolume: (_ volume: Float) -> Void

  static let liveValue: Self = {

    func getDefaultDevice() -> AudioDeviceID {
      var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultOutputDevice,
        mScope: kAudioObjectPropertyScopeOutput,
        mElement: kAudioObjectPropertyElementMain
      )

      var value = AudioDeviceID()
      var valueSIze = UInt32(MemoryLayout.size(ofValue: value))
      let status = AudioObjectGetPropertyData(
        UInt32(kAudioObjectSystemObject),
        &propertyAddress,
        0,
        nil,
        &valueSIze,
        &value)

      return value
    }

    return Self(
      getVolume: {
        var volume = Float32(0.0)
        var volumeSize = UInt32(MemoryLayout.size(ofValue: volume))

        var volumePropertyAddress = AudioObjectPropertyAddress(
          mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
          mScope: kAudioDevicePropertyScopeOutput,
          mElement: kAudioObjectPropertyElementMain)

        let status = AudioObjectGetPropertyData(
          getDefaultDevice(),
          &volumePropertyAddress,
          0,
          nil,
          &volumeSize,
          &volume)

        return volume
      },
      setVolume: {
        var volume = $0
        var volumeSize = UInt32(MemoryLayout.size(ofValue: volume))

        var volumePropertyAddress = AudioObjectPropertyAddress(
          mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
          mScope: kAudioDevicePropertyScopeOutput,
          mElement: kAudioObjectPropertyElementMain)

        let status = AudioObjectSetPropertyData(
          getDefaultDevice(),
          &volumePropertyAddress,
          0,
          nil,
          volumeSize,
          &volume)
      }
    )
  }()
}
