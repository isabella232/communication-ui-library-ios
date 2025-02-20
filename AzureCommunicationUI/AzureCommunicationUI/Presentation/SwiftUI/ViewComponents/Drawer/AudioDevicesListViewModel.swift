//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AVFoundation

class AudioDevicesListViewModel: ObservableObject {
    @Published var audioDevicesList: [AudioDevicesListCellViewModel] = []

    private var audioDeviceStatus: LocalUserState.AudioDeviceSelectionStatus
    private var previousConnectedDevice: AudioDeviceType?
    private let dispatch: ActionDispatch
    private let localizationProvider: LocalizationProvider

    init(dispatchAction: @escaping ActionDispatch,
         localUserState: LocalUserState,
         localizationProvider: LocalizationProvider) {
        self.dispatch = dispatchAction
        self.audioDeviceStatus = localUserState.audioState.device
        self.localizationProvider = localizationProvider
    }

    func update(audioDeviceStatus: LocalUserState.AudioDeviceSelectionStatus) {
        if audioDeviceStatus != self.audioDeviceStatus || audioDevicesList.isEmpty,
           LocalUserState.AudioDeviceSelectionStatus.isSelected(for: audioDeviceStatus) {
            self.audioDeviceStatus = audioDeviceStatus
            self.audioDevicesList = getAvailableAudioDevices(audioDeviceStatus: audioDeviceStatus)
        }
    }

    private func getAvailableAudioDevices(audioDeviceStatus: LocalUserState.AudioDeviceSelectionStatus)
    -> [AudioDevicesListCellViewModel] {
        let systemDefaultAudio: AudioDeviceType
        switch audioDeviceStatus {
        case .bluetoothSelected:
            systemDefaultAudio = .bluetooth
        case .headphonesSelected:
            systemDefaultAudio = .headphones
        case .receiverSelected:
            systemDefaultAudio = .receiver
        default:
            if let availableInputs = AVAudioSession.sharedInstance().availableInputs {
                let availableInputPorts = Set(availableInputs.map({ $0.portType }))
                let isBluetoothConnected = !availableInputPorts.isDisjoint(with: bluetoothAudioPorts)
                let isHeadphonesConnected = !availableInputPorts.isDisjoint(with: headphonesAudioPorts)

                if isBluetoothConnected,
                   isHeadphonesConnected,
                   let previousConnectedDevice = previousConnectedDevice {
                    systemDefaultAudio = previousConnectedDevice
                } else if isBluetoothConnected {
                    systemDefaultAudio = .bluetooth
                } else if isHeadphonesConnected {
                    systemDefaultAudio = .headphones
                } else {
                    systemDefaultAudio = .receiver
                }
            } else {
                systemDefaultAudio = .receiver
            }
        }
        previousConnectedDevice = systemDefaultAudio

        var audioDeviceOptions = [AudioDevicesListCellViewModel]()
        audioDeviceOptions.append(getAudioDeviceOption(for: systemDefaultAudio))
        audioDeviceOptions.append(getAudioDeviceOption(for: .speaker))
        return audioDeviceOptions
    }

    private func getAudioDeviceOption(for audioDeviceType: AudioDeviceType) -> AudioDevicesListCellViewModel {
        let isSelected = isAudioDeviceSelected(audioDeviceType, selectedDevice: audioDeviceStatus)
        let action = LocalUserAction.AudioDeviceChangeRequested(device: audioDeviceType)
        let audioDeviceOption = AudioDevicesListCellViewModel(
            icon: getAudioDeviceIcon(audioDeviceType),
            title: getAudioDeviceTitle(audioDeviceType),
            isSelected: isSelected,
            onSelected: { [weak self] in self?.dispatch(action) })
        return audioDeviceOption
    }

    private func getAudioDeviceTitle(_ audioDeviceType: AudioDeviceType) -> String {
        switch audioDeviceType {
        case .bluetooth:
            return audioDeviceType.getBluetoothName() ?? localizationProvider
                .getLocalizedString(audioDeviceType.name)
        default:
            return localizationProvider.getLocalizedString(audioDeviceType.name)
        }
    }

    private func getAudioDeviceIcon(_ audioDeviceType: AudioDeviceType) -> CompositeIcon {
        switch audioDeviceType {
        case .bluetooth:
            return .speakerBluetooth
        case .speaker:
            return .speakerFilled
        default:
            return .speakerRegular
        }
    }

    private func isAudioDeviceSelected(_ audioDeviceType: AudioDeviceType,
                                       selectedDevice: LocalUserState.AudioDeviceSelectionStatus) -> Bool {
        switch selectedDevice {
        case .bluetoothSelected where audioDeviceType == .bluetooth,
             .headphonesSelected where audioDeviceType == .headphones,
             .receiverSelected where audioDeviceType == .receiver,
             .speakerSelected where audioDeviceType == .speaker:
            return true
        default:
            return false
        }
    }
}
