//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AVFoundation
import Combine

protocol AudioSessionManager {

}

class AppAudioSessionManager: AudioSessionManager {
    private let logger: Logger
    private let store: Store<AppState>
    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState>,
         logger: Logger) {
        self.store = store
        self.logger = logger
        let currentAudioDevice = getCurrentAudioDevice()
        self.setupAudioSession()
        store.dispatch(action: LocalUserAction.AudioDeviceChangeRequested(device: currentAudioDevice))
        store.$state
            .sink { [weak self] state in
                self?.receive(state: state)
            }.store(in: &cancellables)
    }

    private func receive(state: AppState) {
        let localUserState = state.localUserState
        handle(state: localUserState.audioState.device)
    }

    private func handle(state: LocalUserState.AudioDeviceSelectionStatus) {
        switch state {
        case .speakerRequested:
            switchAudioDevice(to: .speaker)
        case .receiverRequested:
            switchAudioDevice(to: .receiver)
        default:
            break
        }
    }

    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            let options: AVAudioSession.CategoryOptions = [.allowBluetooth,
                                                           .duckOthers,
                                                           .interruptSpokenAudioAndMixWithOthers,
                                                           .allowBluetoothA2DP]
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: options)
            try audioSession.setActive(true)
        } catch let error {
            logger.error("Failed to set audio session category:\(error.localizedDescription)")
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: AVAudioSession.sharedInstance())
    }

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                print("---------------handle interruption failed")
                return
        }

        // Switch over the interruption type.
        switch type {

        case .began:
            // An interruption began. Update the UI as necessary.
            print("---------------An interruption began")
        case .ended:
           // An interruption ended. Resume playback, if appropriate.
            print("---------------An interruption ended")

            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                print("---------------Resume playback")

                // An interruption ended. Resume playback.
            } else {
                print("---------------Don't resume playback")

                // An interruption ended. Don't resume playback.
            }

        default: ()
        }
    }

    private func getCurrentAudioDevice() -> AudioDeviceType {
        let audioSession = AVAudioSession.sharedInstance()

        for output in audioSession.currentRoute.outputs where output.portType == .builtInSpeaker {
            return .speaker
        }
        return .receiver
    }

    private func switchAudioDevice(to selectedAudioDevice: AudioDeviceType) {
        let audioSession = AVAudioSession.sharedInstance()

        let audioPort: AVAudioSession.PortOverride
        switch selectedAudioDevice {
        case .receiver:
            audioPort = .none
        case .speaker:
            audioPort = .speaker
        }

        do {
            try audioSession.setActive(true)
            try audioSession.overrideOutputAudioPort(audioPort)
            store.dispatch(action: LocalUserAction.AudioDeviceChangeSucceeded(device: selectedAudioDevice))
        } catch let error {
            logger.error("Failed to select audio device, reason:\(error.localizedDescription)")
            store.dispatch(action: LocalUserAction.AudioDeviceChangeFailed(error: error))
        }
    }

    @objc func handleRouteChange(notification: Notification) {
        store.dispatch(action: LocalUserAction.AudioDeviceChangeRequested(device: getCurrentAudioDevice()))
    }
}
