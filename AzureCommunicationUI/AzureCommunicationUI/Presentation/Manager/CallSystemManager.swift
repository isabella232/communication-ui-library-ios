//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AVFoundation
import CallKit
import Combine

protocol CallSystemManager {

}

class CallKitManager: NSObject, CallSystemManager {
    private let logger: Logger
    private let store: Store<AppState>
    private var callStatus: CallingStatus = .none
    private let callingId = UUID()
    var cancellables = Set<AnyCancellable>()

    let callKitProvider: CXProvider
    let callKitCallController: CXCallController
//    var callKitCompletionHandler: ((Bool) -> Void)? = nil
    var userInitiatedDisconnect: Bool = false

    init(store: Store<AppState>,
         logger: Logger) {
        self.logger = logger
        self.store = store

        let providerConfig = CXProviderConfiguration(localizedName: "CallKit")
        providerConfig.supportsVideo = true
        providerConfig.maximumCallsPerCallGroup = 1
        providerConfig.includesCallsInRecents = true
        providerConfig.supportedHandleTypes = [.generic]
        callKitCallController = CXCallController()
        callKitProvider = CXProvider(configuration: providerConfig)
        super.init()
        callKitProvider.setDelegate(self, queue: nil)
        store.$state
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
        print("---------provider::setDelegate")
    }

    private func receive(_ state: AppState) {
        let newCallingStatus = state.callingState.status
        guard newCallingStatus != callStatus else {
            return
        }
        callStatus = newCallingStatus
        if callStatus == .connected {
            startCall()
        }
    }

    func startCall() {
        let handle = CXHandle(type: .generic, value: "")
        let startCallAction = CXStartCallAction(call: callingId, handle: handle)

        startCallAction.isVideo = true

        let transaction = CXTransaction()
        transaction.addAction(startCallAction)

        requestTransaction(transaction)
    }

//    func end(call: String) {
//        let endCallAction = CXEndCallAction(call: call.uuid)
//        let transaction = CXTransaction()
//        transaction.addAction(endCallAction)
//
//        requestTransaction(transaction)
//    }

    private func requestTransaction(_ transaction: CXTransaction) {
        callKitCallController.request(transaction) { error in
            if let error = error {
                print("------Error requesting transaction:", error.localizedDescription)
            } else {
                let update = CXCallUpdate()
                update.supportsHolding = true
                update.hasVideo = false
                self.callKitProvider.reportCall(with: self.callingId, updated: update)
                print("------Requested transaction successfully")
            }
        }
    }
}

extension CallKitManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {

    }

    func providerDidBegin(_ provider: CXProvider) {
        print("---------provider::providerDidBegin:")
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("---------provider::didActivateAudioSession:")
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("---------provider::didDeactivateAudioSession:")
    }
}
