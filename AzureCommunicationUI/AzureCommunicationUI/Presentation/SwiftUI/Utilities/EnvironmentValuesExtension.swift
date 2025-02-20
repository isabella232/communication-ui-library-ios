//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

enum ScreenSizeClassType {
    case iphonePortraitScreenSize
    // iPhone portrait screen, iPad split view (compact width, regular height)

    case iphoneLandscapeScreenSize
    // iPhone landscape screen (compact width, compact height), (regular width, compact height)

    case ipadScreenSize
    // iPad screen (regular width, regular height)
}

struct ScreenSizeClassKey: EnvironmentKey {
    static let defaultValue: ScreenSizeClassType = .iphonePortraitScreenSize
}

struct AppPhaseKey: EnvironmentKey {
    static let defaultValue: AppStatus = .foreground
}

extension EnvironmentValues {
    var screenSizeClass: ScreenSizeClassType {
        get { self[ScreenSizeClassKey.self] }
        set { self[ScreenSizeClassKey.self] = newValue }
    }

    var appPhase: AppStatus {
        get { self[AppPhaseKey.self] }
        set { self[AppPhaseKey.self] = newValue }
    }
}
