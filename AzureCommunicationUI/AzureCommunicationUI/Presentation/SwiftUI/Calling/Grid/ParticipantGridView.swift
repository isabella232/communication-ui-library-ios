//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ParticipantGridView: View {
    let viewModel: ParticipantGridViewModel
    let videoViewManager: VideoViewManager
    let screenSize: ScreenSizeClassType
    @State var participantsCellViewModelArr: [ParticipantGridCellViewModel] = []
    var body: some View {
        return Group {
            ParticipantGridLayoutView(cellViewModels: $participantsCellViewModelArr,
                                      getRemoteParticipantRendererView: getRemoteParticipantRendererView(videoViewId:),
                                      rendererViewManager: videoViewManager,
                                      screenSize: screenSize)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onReceive(viewModel.$displayedParticipantInfoModelArr) {
                updateVideoViewManager(displayedRemoteInfoModelArr: $0)
            }
            .onReceive(viewModel.$participantsCellViewModelArr) { models in
                participantsCellViewModelArr = models
            }
    }

    func getRemoteParticipantRendererView(videoViewId: RemoteParticipantVideoViewId) -> ParticipantRendererViewInfo? {
        return videoViewManager.getRemoteParticipantVideoRendererView(videoViewId)
    }

    func updateVideoViewManager(displayedRemoteInfoModelArr: [ParticipantInfoModel]) {
        let videoCacheIds: [RemoteParticipantVideoViewId] = displayedRemoteInfoModelArr.compactMap {
            let screenShareVideoStreamIdentifier = $0.screenShareVideoStreamModel?.videoStreamIdentifier
            let cameraVideoStreamIdentifier = $0.cameraVideoStreamModel?.videoStreamIdentifier
            guard let videoStreamIdentifier = screenShareVideoStreamIdentifier ?? cameraVideoStreamIdentifier else {
                return nil
            }
            return RemoteParticipantVideoViewId(userIdentifier: $0.userIdentifier,
                                                videoStreamIdentifier: videoStreamIdentifier)
        }
        videoViewManager.updateDisplayedRemoteVideoStream(videoCacheIds)
    }
}
