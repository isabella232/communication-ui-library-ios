//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import SwiftUI
import AzureCommunicationCommon

class CompositeAvatarViewModel: ObservableObject {
    @Published var avatarImage: UIImage?
    let config: ParticipantConfiguration

    init(_ config: ParticipantConfiguration) {
        self.config = config
    }

    func fetchAvatarImage(for identifier: CommunicationIdentifier) {
        config.avatar(identifier) { [weak self] image in
            self?.avatarImage = image
        }
    }
}
