//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import AzureCommunicationCommon

public class AvatarManager {
    static let LocalKey: String = "local"

    private let store: Store<AppState>
    private weak var eventsHandler: CallCompositeEventsHandler?
    private var avatarCache = MappedSequence<String, Data>()

    init(store: Store<AppState>,
         callCompositeEventHandler: CallCompositeEventsHandler?) {
        self.store = store
        self.eventsHandler = callCompositeEventHandler
    }

    func setLocalAvatar(_ image: UIImage) {
        if let rawData = image.pngData() {
            avatarCache.append(forKey: AvatarManager.LocalKey, value: rawData)
        }
    }

    func getLocalAvatar() -> UIImage? {
        if let data = avatarCache.value(forKey: AvatarManager.LocalKey) {
            return UIImage(data: data)
        }

        return nil
    }

    public func setRemoteAvatar(for identifier: CommunicationIdentifier,
                                persona: PersonaData) {
        guard let rawIdentifier = identifier.stringValue else {
            return
        }

        if let rawData = persona.avatar?.pngData() {
            avatarCache.append(forKey: rawIdentifier, value: rawData)
        }
    }

    func onRemoteParticipantReady(for identifier: CommunicationIdentifier) {
        guard let handler = eventsHandler?.onRemoteParticipant else {
            return
        }

        handler(identifier, self)
    }

    func getRemoteAvatar(for identifier: CommunicationIdentifier) -> UIImage? {
        guard let rawIdentifier = identifier.stringValue else {
            return nil
        }

        if let rawData = avatarCache.value(forKey: rawIdentifier) {
            return UIImage(data: rawData)
        }

        return nil
    }
}
