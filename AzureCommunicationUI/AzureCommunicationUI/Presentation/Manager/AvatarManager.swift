//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import AzureCommunicationCommon

class AvatarManager {
    static let LocalKey: String = "local"

    private let store: Store<AppState>
    private var avatarCache = MappedSequence<String, Data>()

    init(store: Store<AppState>) {
        self.store = store
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

    func setRemoteAvatar(for identifier: CommunicationIdentifier,
                         persona: PersonaData) {
        guard let rawIdentifier = identifier.stringValue else {
            return
        }

        if let rawData = persona.avatar?.pngData() {
            avatarCache.append(forKey: rawIdentifier, value: rawData)
        }

        guard let image = persona.avatar else {
            return
        }
    }
}
