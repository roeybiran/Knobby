import AudioToolbox
import Foundation

// https://stackoverflow.com/a/27291862

struct AudioToolboxClient {
  var getVolume: () -> Float
  var setVolume: (_ volume: Float) -> Void

  static let liveValue: Self = {
    var defaultOutputDeviceID = AudioDeviceID(0)
    var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
    var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
      mSelector: kAudioHardwarePropertyDefaultOutputDevice,
      mScope: kAudioObjectPropertyScopeGlobal,
      mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMain))

    let status = AudioObjectGetPropertyData(
      AudioObjectID(kAudioObjectSystemObject),
      &getDefaultOutputDevicePropertyAddress,
      0,
      nil,
      &defaultOutputDeviceIDSize,
      &defaultOutputDeviceID)

    return Self(
      getVolume: {
        var volume = Float(0.0)
        var volumeSize = UInt32(MemoryLayout.size(ofValue: volume))

        var volumePropertyAddress = AudioObjectPropertyAddress(
          mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
          mScope: kAudioDevicePropertyScopeOutput,
          mElement: kAudioObjectPropertyElementMain)

        let status = AudioObjectGetPropertyData(
          defaultOutputDeviceID,
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
          defaultOutputDeviceID,
          &volumePropertyAddress,
          0,
          nil,
          volumeSize,
          &volume)
      }
    )
  }()
}
