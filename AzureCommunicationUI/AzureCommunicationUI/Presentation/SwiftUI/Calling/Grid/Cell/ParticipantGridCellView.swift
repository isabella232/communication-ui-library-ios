//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import Combine

struct ParticipantGridCellView: View {
    @ObservedObject var viewModel: ParticipantGridCellViewModel
    @State var displayedParticipantRendererViewInfo: ParticipantRendererViewInfo?
    @State var videoStreamId: String?
    let getRemoteParticipantRendererView: (RemoteParticipantVideoViewId) -> ParticipantRendererViewInfo?
    let rendererViewManager: RendererViewManager?
    let avatarSize: CGFloat = 56

    var body: some View {
        Group {
            GeometryReader { geometry in
                if let rendererViewInfo = displayedParticipantRendererViewInfo {
                    let zoomable = viewModel.videoViewModel?.videoStreamType == .screenSharing
                    ParticipantGridCellVideoView(videoRendererViewInfo: rendererViewInfo,
                                                 rendererViewManager: rendererViewManager,
                                                 zoomable: zoomable,
                                                 isSpeaking: $viewModel.isSpeaking,
                                                 displayName: $viewModel.displayName,
                                                 isMuted: $viewModel.isMuted)
                } else {
                    avatarView
                        .frame(width: geometry.size.width,
                               height: geometry.size.height)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(viewModel.accessibilityLabel))
        }
        .onReceive(viewModel.$videoViewModel) { model in
            guard videoStreamId != model?.videoStreamId
            else { return }

            videoStreamId = model?.videoStreamId
            displayedParticipantRendererViewInfo = getRendererViewInfo(for: videoStreamId)
        }
    }

    func getRendererViewInfo(for videoStreamId: String?) -> ParticipantRendererViewInfo? {
        guard let remoteParticipantVideoStreamId = videoStreamId,
              !remoteParticipantVideoStreamId.isEmpty else {
            return nil
        }
        let userId = viewModel.participantIdentifier
        let remoteParticipantVideoViewId = RemoteParticipantVideoViewId(userIdentifier: userId,
                                            videoStreamIdentifier: remoteParticipantVideoStreamId)
        return getRemoteParticipantRendererView(remoteParticipantVideoViewId)
    }

    var avatarView: some View {
        VStack(alignment: .center, spacing: 5) {
            CompositeAvatar(displayName: $viewModel.displayName,
                            isSpeaking: viewModel.isSpeaking && !viewModel.isMuted)
                .frame(width: avatarSize, height: avatarSize)
            Spacer().frame(height: 10)
            ParticipantTitleView(displayName: $viewModel.displayName,
                                 isMuted: $viewModel.isMuted,
                                 titleFont: Fonts.button1.font,
                                 mutedIconSize: 16)
        }
    }

}

struct ParticipantTitleView: View {
    @Binding var displayName: String?
    @Binding var isMuted: Bool
    let titleFont: Font
    let mutedIconSize: CGFloat
    private let hSpace: CGFloat = 4
    private var isEmpty: Bool {
        return !isMuted && displayName?.trimmingCharacters(in: .whitespaces).isEmpty == true
    }

    var body: some View {
        HStack(alignment: .center, spacing: hSpace, content: {
            if let displayName = displayName,
               !displayName.trimmingCharacters(in: .whitespaces).isEmpty {
                Text(displayName)
                    .font(titleFont)
                    .lineLimit(1)
                    .foregroundColor(Color(StyleProvider.color.onBackground))
            }
            if isMuted {
                Icon(name: .micOff, size: mutedIconSize)
            }
        })
        .padding(.horizontal, isEmpty ? 0 : 4)
        .animation(.default)
    }
}
