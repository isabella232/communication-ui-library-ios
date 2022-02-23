//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import AzureCommunicationCommon

struct ParticipantInfoModel: Equatable {
    let displayName: String
    let avatar: UIImage?
    let isSpeaking: Bool
    let isMuted: Bool

    let isRemoteUser: Bool
    let userIdentifier: CommunicationIdentifier

    let recentSpeakingStamp: Date

    let screenShareVideoStreamModel: VideoStreamInfoModel?
    let cameraVideoStreamModel: VideoStreamInfoModel?
}

extension ParticipantInfoModel {
    static func == (lhs: ParticipantInfoModel, rhs: ParticipantInfoModel) -> Bool {
        return (lhs.displayName == rhs.displayName &&
                lhs.avatar == rhs.avatar &&
                lhs.isSpeaking == rhs.isSpeaking &&
                lhs.isMuted == rhs.isMuted &&
                lhs.isRemoteUser == rhs.isRemoteUser &&
                lhs.userIdentifier.stringValue == rhs.userIdentifier.stringValue &&
                lhs.recentSpeakingStamp.timeIntervalSince1970 ==
                rhs.recentSpeakingStamp.timeIntervalSince1970 &&
                lhs.screenShareVideoStreamModel == rhs.screenShareVideoStreamModel &&
                lhs.cameraVideoStreamModel == rhs.cameraVideoStreamModel)
    }
}
