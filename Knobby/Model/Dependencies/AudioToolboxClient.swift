import AudioToolbox
import Foundation

struct AudioToolboxClient {
  struct Device: Identifiable, Hashable {
    let id: AudioDeviceID
    let name: String
  }

  var outputDevices: () -> [Device]
  var getVolume: (_ deviceID: AudioDeviceID) -> Float
  var setVolume: (_ deviceID: AudioDeviceID, _ volume: Float) -> Void

  static let liveValue: Self = {
    Self(
      outputDevices: {
        var devicesAddress = AudioObjectPropertyAddress(
          mSelector: kAudioHardwarePropertyDevices,
          mScope: kAudioObjectPropertyScopeGlobal,
          mElement: kAudioObjectPropertyElementMain
        )

        var devicesSize = UInt32.zero
        guard AudioObjectGetPropertyDataSize(
          AudioObjectID(kAudioObjectSystemObject),
          &devicesAddress,
          0,
          nil,
          &devicesSize
        ) == noErr else { return [] }

        let deviceCount = Int(devicesSize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)
        let deviceStatus = deviceIDs.withUnsafeMutableBytes { bytes in
          guard let baseAddress = bytes.baseAddress else { return noErr }
          return AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &devicesAddress,
            0,
            nil,
            &devicesSize,
            baseAddress
          )
        }
        guard deviceStatus == noErr else { return [] }

        var defaultDeviceAddress = AudioObjectPropertyAddress(
          mSelector: kAudioHardwarePropertyDefaultOutputDevice,
          mScope: kAudioObjectPropertyScopeOutput,
          mElement: kAudioObjectPropertyElementMain
        )
        var defaultDevice = AudioDeviceID.zero
        var defaultDeviceSize = UInt32(MemoryLayout.size(ofValue: defaultDevice))
        if AudioObjectGetPropertyData(
          AudioObjectID(kAudioObjectSystemObject),
          &defaultDeviceAddress,
          0,
          nil,
          &defaultDeviceSize,
          &defaultDevice
        ) != noErr {
          defaultDevice = .zero
        }

        return deviceIDs.compactMap { deviceID in
          var streamConfigurationAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
          )
          guard AudioObjectHasProperty(deviceID, &streamConfigurationAddress) else { return nil }

          var streamConfigurationSize = UInt32.zero
          guard AudioObjectGetPropertyDataSize(
            deviceID,
            &streamConfigurationAddress,
            0,
            nil,
            &streamConfigurationSize
          ) == noErr else { return nil }

          let streamConfigurationPointer = UnsafeMutableRawPointer.allocate(
            byteCount: Int(streamConfigurationSize),
            alignment: MemoryLayout<AudioBufferList>.alignment
          )
          defer { streamConfigurationPointer.deallocate() }

          guard AudioObjectGetPropertyData(
            deviceID,
            &streamConfigurationAddress,
            0,
            nil,
            &streamConfigurationSize,
            streamConfigurationPointer
          ) == noErr else { return nil }

          let bufferList = streamConfigurationPointer.assumingMemoryBound(to: AudioBufferList.self)
          let outputBuffers = UnsafeMutableAudioBufferListPointer(bufferList)
          if !outputBuffers.contains(where: { $0.mNumberChannels > 0 }) {
            return nil
          }

          var volumeAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
          )
          guard AudioObjectHasProperty(deviceID, &volumeAddress) else { return nil }

          var isSettable = DarwinBoolean(false)
          guard AudioObjectIsPropertySettable(deviceID, &volumeAddress, &isSettable) == noErr else {
            return nil
          }
          if !isSettable.boolValue {
            return nil
          }

          var nameAddress = AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertyName,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
          )
          var name = "" as CFString
          var nameSize = UInt32(MemoryLayout<CFString>.size)
          guard AudioObjectGetPropertyData(
            deviceID,
            &nameAddress,
            0,
            nil,
            &nameSize,
            &name
          ) == noErr else { return nil }

          return Device(id: deviceID, name: name as String)
        }
        .sorted { lhs, rhs in
          if lhs.id == defaultDevice {
            return true
          }
          if rhs.id == defaultDevice {
            return false
          }
          return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        }
      },
      getVolume: { deviceID in
        var volume = Float32.zero
        var volumeSize = UInt32(MemoryLayout.size(ofValue: volume))
        var volumeAddress = AudioObjectPropertyAddress(
          mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
          mScope: kAudioDevicePropertyScopeOutput,
          mElement: kAudioObjectPropertyElementMain
        )

        guard AudioObjectGetPropertyData(
          deviceID,
          &volumeAddress,
          0,
          nil,
          &volumeSize,
          &volume
        ) == noErr else { return .zero }

        return volume
      },
      setVolume: { deviceID, volume in
        var clampedVolume = max(0, min(1, volume))
        let volumeSize = UInt32(MemoryLayout.size(ofValue: clampedVolume))
        var volumeAddress = AudioObjectPropertyAddress(
          mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
          mScope: kAudioDevicePropertyScopeOutput,
          mElement: kAudioObjectPropertyElementMain
        )

        _ = AudioObjectSetPropertyData(
          deviceID,
          &volumeAddress,
          0,
          nil,
          volumeSize,
          &clampedVolume
        )
      }
    )
  }()
}
