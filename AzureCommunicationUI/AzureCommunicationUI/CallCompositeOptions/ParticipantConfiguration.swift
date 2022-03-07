//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import AzureCommunicationCommon

public typealias FetchImageAction = (UIImage?) -> Void
// Potential name change here
public struct PersonaData {
    var displayName: String? // Local
    var avatar: UIImage?

    public init(displayName: String = "",
                avatar: UIImage? = nil) {
        self.displayName = displayName
        self.avatar = avatar
    }
}

public protocol LocalConfiguration {
    func localPersona(_ composite: ICallComposite)
}

public protocol ParticipantConfiguration {
    func avatar(_ identifier: CommunicationIdentifier,
                onImageCompleted: @escaping FetchImageAction)
}
