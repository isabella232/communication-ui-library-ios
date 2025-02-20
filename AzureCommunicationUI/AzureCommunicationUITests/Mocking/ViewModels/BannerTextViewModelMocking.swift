//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationCalling
@testable import AzureCommunicationUI

class BannerTextViewModelMocking: BannerTextViewModel {
    var updateBannerInfoType: ((BannerInfoType?) -> Void)?
    var bannerType: BannerInfoType?

    init(accessibilityProvider: AccessibilityProvider = AppAccessibilityProvider(),
         updateBannerInfoType: ((BannerInfoType?) -> Void)? = nil) {
        self.updateBannerInfoType = updateBannerInfoType
        super.init(accessibilityProvider: accessibilityProvider,
                   localizationProvider: LocalizationProviderMocking())
    }

    override func update(bannerInfoType: BannerInfoType?) {
        updateBannerInfoType?(bannerInfoType)
    }
}
