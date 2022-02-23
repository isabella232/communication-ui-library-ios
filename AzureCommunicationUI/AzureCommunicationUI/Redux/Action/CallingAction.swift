//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

struct CallingAction {
    struct CallStartRequested: Action {}

    struct CallEndRequested: Action {}

    struct StateUpdated: Action {
        let status: CallingStatus
    }

    struct SetupCall: Action {}

    struct DismissSetup: Action {}

    struct RecordingStateUpdated: Action {
        let isRecordingActive: Bool
    }

    struct TranscriptionStateUpdated: Action {
        let isTranscriptionActive: Bool
    }
}

struct ParticipantListUpdated: Action {
    let participantsInfoList: [ParticipantInfoModel]
}

struct ParticipantAvatarSet: Action {
    let uniqueIdentifier: String
    let image: UIImage
}

struct ErrorAction: Action {
    struct FatalErrorUpdated: Action {
        let error: ErrorEvent
    }

    struct CallStateErrorUpdated: Action {
        let error: ErrorEvent
    }
}

struct CompositeExitAction: Action {}

struct CallingViewLaunched: Action {
}
