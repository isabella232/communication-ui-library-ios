//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

class InfoHeaderViewModelMocking: InfoHeaderViewModel {
    private let updateState: ((LocalUserState, RemoteParticipantsState, CallingState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         localUserState: LocalUserState,
         accessibilityProvider: AccessibilityProvider,
         updateState: ((LocalUserState, RemoteParticipantsState, CallingState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   logger: logger,
                   localUserState: localUserState,
                   localizationProvider: LocalizationProviderMocking(),
                   accessibilityProvider: accessibilityProvider)
    }

    override func update(localUserState: LocalUserState,
                         remoteParticipantsState: RemoteParticipantsState,
                         callingState: CallingState) {
        updateState?(localUserState, remoteParticipantsState, callingState)
    }
}
