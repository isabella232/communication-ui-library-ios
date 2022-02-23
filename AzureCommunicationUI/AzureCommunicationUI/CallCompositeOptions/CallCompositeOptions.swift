//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

/// User-configurable options for creating CallComposite.
public struct CallCompositeOptions {
    var themeConfiguration: ThemeConfiguration?
    var localConfiguration: LocalConfiguration?
    var localPersona: PersonaData?
    var participantConfiguration: ParticipantConfiguration?
    /// Creates an instance of CallCompositeOptions with related options.
    /// - Parameter themeConfiguration: ThemeConfiguration for changing color pattern
    public init(themeConfiguration: ThemeConfiguration? = nil,
                localConfiguration: LocalConfiguration? = nil,
                participantConfiguration: ParticipantConfiguration? = nil) {
        self.themeConfiguration = themeConfiguration
        self.localConfiguration = localConfiguration
        self.participantConfiguration = participantConfiguration
    }

    public init() { }
}
