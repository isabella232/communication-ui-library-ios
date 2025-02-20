//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

extension UIDevice {

    /// Returns `true` if the device has a home bar in landscape
    var hasHomeBar: Bool {
        guard #available(iOS 11.0, *), let window =
            UIApplication.shared.windows.filter({$0.isKeyWindow}).first
        else {
            return false
        }

        return window.safeAreaInsets.bottom > 0
    }

    func toggleProximityMonitoringStatus(isEnabled: Bool) {
        UIDevice.current.isProximityMonitoringEnabled = isEnabled
    }
}
