//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

/// A protocol to allow customizing the theme.
public protocol ThemeConfiguration {

    /// Provide a getter to return a custom primary color.
    var primaryColor: UIColor { get }

    /// Override color scheme to be light or dark.
    var colorSchemeOverride: UIUserInterfaceStyle { get }
}

public extension ThemeConfiguration {
    var primaryColor: UIColor {
        return UIColor.compositeColor(.primary)
    }
    var colorSchemeOverride: UIUserInterfaceStyle {
        return .unspecified
    }
}
