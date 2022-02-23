//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

struct CallConfiguration {
    let communicationTokenCredential: CommunicationTokenCredential
    let displayName: String?
    let participantConfiguration: ParticipantConfiguration?
    let groupId: UUID?
    let meetingLink: String?
    let compositeCallType: CompositeCallType
    let diagnosticConfig: DiagnosticConfig

    init(communicationTokenCredential: CommunicationTokenCredential,
         groupId: UUID,
         displayName: String?,
         participantConfiguration: ParticipantConfiguration? = nil) {
        self.communicationTokenCredential = communicationTokenCredential
        self.displayName = displayName
        self.participantConfiguration = participantConfiguration
        self.groupId = groupId
        self.meetingLink = nil
        self.compositeCallType = .groupCall
        self.diagnosticConfig = DiagnosticConfig()
    }

    init(communicationTokenCredential: CommunicationTokenCredential,
         meetingLink: String,
         displayName: String?,
         participantConfiguration: ParticipantConfiguration? = nil) {
        self.communicationTokenCredential = communicationTokenCredential
        self.displayName = displayName
        self.participantConfiguration = participantConfiguration
        self.groupId = nil
        self.meetingLink = meetingLink
        self.compositeCallType = .teamsMeeting
        self.diagnosticConfig = DiagnosticConfig()
    }
}

enum CompositeCallType {
    case groupCall
    case teamsMeeting
}
