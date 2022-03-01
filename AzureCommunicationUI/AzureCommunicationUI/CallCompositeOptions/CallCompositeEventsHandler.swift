//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import UIKit
import AzureCommunicationCalling

public class LocalManager {
    var persona: PersonaData?
    private var avatarManager: AvatarManager?

    init(avatarManager: AvatarManager) {
        self.persona = nil
        self.avatarManager = avatarManager
    }

    public func setLocalPersonaData(_ newPersona: PersonaData) {
        self.persona = newPersona
        guard let avatarManager = avatarManager,
              let avatar = newPersona.avatar else {
            return
        }
        avatarManager.setLocalAvatar(avatar)
    }
}

class CallCompositeEventsHandler {
    var didFail: ((ErrorEvent) -> Void)?
    var onLocalParticipantJoined:((_ previousData: PersonaData?, _ manager: LocalManager) -> Void)?
    var onRemoteParticipant: ((CommunicationIdentifier, AvatarManager) -> Void)?
}
