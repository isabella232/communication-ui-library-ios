//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import AzureCommunicationCommon

struct ParticipantGridView: View {
    let viewModel: ParticipantGridViewModel
    let videoViewManager: VideoViewManager
    let avatarManager: AvatarManager
    let screenSize: ScreenSizeClassType
    @State var gridsCount: Int = 0

    var body: some View {
        return Group {
            ParticipantGridLayoutView(cellViewModels: viewModel.participantsCellViewModelArr,
                                      getRemoteParticipantRendererView: getRemoteParticipantRendererView(videoViewId:),
                                      getRemoteParticipantAvater: getRemoteParticipantAvatar(for:),
                                      screenSize: screenSize)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(gridsCount)
            .onReceive(viewModel.$gridsCount) {
                gridsCount = $0
            }
            .onReceive(viewModel.$displayedParticipantInfoModelArr) {
                updateVideoViewManager(displayedRemoteInfoModelArr: $0)
                updateParticipantAvatarManager(displayedRemoteInfoModelArr: $0)
            }
    }

    func getRemoteParticipantRendererView(videoViewId: RemoteParticipantVideoViewId) -> UIView? {
        return videoViewManager.getRemoteParticipantVideoRendererView(videoViewId)
    }

    func getRemoteParticipantAvatar(for identifier: CommunicationIdentifier) -> UIImage? {
        return avatarManager.getRemoteAvatar(for: identifier)
    }

    func updateVideoViewManager(displayedRemoteInfoModelArr: [ParticipantInfoModel]) {
        let videoCacheIds: [RemoteParticipantVideoViewId] = displayedRemoteInfoModelArr.compactMap {
            let screenShareVideoStreamIdentifier = $0.screenShareVideoStreamModel?.videoStreamIdentifier
            let cameraVideoStreamIdentifier = $0.cameraVideoStreamModel?.videoStreamIdentifier
            guard let videoStreamIdentifier = screenShareVideoStreamIdentifier ?? cameraVideoStreamIdentifier else {
                return nil
            }
            if let identifier = $0.userIdentifier.stringValue {
                return RemoteParticipantVideoViewId(userIdentifier: identifier,
                                                    videoStreamIdentifier: videoStreamIdentifier)
            } else {
                return nil
            }
        }

        videoViewManager.updateDisplayedRemoteVideoStream(videoCacheIds)

    }

    func updateParticipantAvatarManager(displayedRemoteInfoModelArr: [ParticipantInfoModel]) {
        for participantModel in displayedRemoteInfoModelArr {
            let identifier = participantModel.userIdentifier
            avatarManager.onRemoteParticipantReady(for: identifier)
        }
    }

}
