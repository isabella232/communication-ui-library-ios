//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import UIKit
import AzureCommunicationCalling

class CallCompositeEventsHandler {
    var didFail: ((ErrorEvent) -> Void)?
    var onLocalParticipant: ((ICallComposite) -> Void)?
    var onRemoteParticipant: ((CommunicationIdentifier, AvatarManager) -> Void)?
}
