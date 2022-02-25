//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import SwiftUI
import FluentUI
import AzureCommunicationCalling

public protocol ICallComposite {
    func setLocalParticipantPersona(for persona: PersonaData)
    func setRemoteParticipantsPersona(for identifier: String, persona: PersonaData)
}

/// The main class representing the entry point for the Call Composite.
public class CallComposite: ICallComposite {
    private var logger: Logger?
    private let themeConfiguration: ThemeConfiguration?
    private let localConfiguration: LocalConfiguration?
    private let participantConfiguration: ParticipantConfiguration?
    private let callCompositeEventsHandler = CallCompositeEventsHandler()
    private var errorManager: ErrorManager?
    private var avatarManager: AvatarManager?
    private var lifeCycleManager: UIKitAppLifeCycleManager?
    private var permissionManager: AppPermissionsManager?
    private var audioSessionManager: AppAudioSessionManager?

    /// Create an instance of CallComposite with options.
    /// - Parameter options: The CallCompositeOptions used to configure the experience.
    public init(withOptions options: CallCompositeOptions) {
        themeConfiguration = options.themeConfiguration
        localConfiguration = options.localConfiguration
        participantConfiguration = options.participantConfiguration
    }

    /// Assign closure to execute when an error occurs inside Call Composite.
    /// - Parameter action: The closure returning the error thrown from Call Composite.
    public func setTarget(didFail action: ((ErrorEvent) -> Void)? = nil,
                          onLocalParticipant: ((ICallComposite) -> Void)? = nil,
                          onRemoteParticipant: ((CommunicationIdentifier, AvatarManager) -> Void)? = nil) {
        callCompositeEventsHandler.didFail = action
        callCompositeEventsHandler.onLocalParticipant = onLocalParticipant
        callCompositeEventsHandler.onRemoteParticipant = onRemoteParticipant
    }

    deinit {
        logger?.debug("Composite deallocated")
    }

    private func launch(_ callConfiguration: CallConfiguration) {
        let dependencyContainer = DependencyContainer()
        logger = dependencyContainer.resolve() as Logger
        logger?.debug("launch composite experience")

        dependencyContainer.registerDependencies(callConfiguration,
                                                 callCompositeEventsHandler: callCompositeEventsHandler)

        setupColorTheming()
        let toolkitHostingController = makeToolkitHostingController(router: dependencyContainer.resolve(),
                                                                    logger: dependencyContainer.resolve(),
                                                                    viewFactory: dependencyContainer.resolve())
        setupManagers(store: dependencyContainer.resolve(),
                      containerHostingController: toolkitHostingController,
                      logger: dependencyContainer.resolve())
        avatarManager = dependencyContainer.resolve() as AvatarManager
        present(toolkitHostingController)
    }

    /// Start call composite experience with joining a group call.
    /// - Parameter options: The GroupCallOptions used to locate the group call.
    public func launch(with options: GroupCallOptions) {
        let callConfiguration = CallConfiguration(
            communicationTokenCredential: options.communicationTokenCredential,
            groupId: options.groupId,
            displayName: options.displayName,
            participantConfiguration: participantConfiguration)

        launch(callConfiguration)
    }

    /// Start call composite experience with joining a Teams meeting..
    /// - Parameter options: The TeamsMeetingOptions used to locate the Teams meetings.
    public func launch(with options: TeamsMeetingOptions) {
        let callConfiguration = CallConfiguration(
            communicationTokenCredential: options.communicationTokenCredential,
            meetingLink: options.meetingLink,
            displayName: options.displayName,
            participantConfiguration: participantConfiguration)

        launch(callConfiguration)
    }

    private func setupManagers(store: Store<AppState>,
                               containerHostingController: ContainerUIHostingController,
                               logger: Logger) {
        let errorManager = CompositeErrorManager(store: store,
                                                 callCompositeEventsHandler: callCompositeEventsHandler)
        self.errorManager = errorManager

        let lifeCycleManager = UIKitAppLifeCycleManager(store: store, logger: logger)
        self.lifeCycleManager = lifeCycleManager

        let permissionManager = AppPermissionsManager(store: store)
        self.permissionManager = permissionManager

        let audioSessionManager = AppAudioSessionManager(store: store,
                                                         logger: logger)
        self.audioSessionManager = audioSessionManager

        guard let onLocalParticipant = callCompositeEventsHandler.onLocalParticipant else {
            return
        }

        onLocalParticipant(self)
    }

    private func cleanUpManagers() {
        self.errorManager = nil
        self.lifeCycleManager = nil
        self.permissionManager = nil
        self.audioSessionManager = nil
    }

    private func makeToolkitHostingController(router: NavigationRouter,
                                              logger: Logger,
                                              viewFactory: CompositeViewFactory) -> ContainerUIHostingController {
        let rootView = ContainerView(router: router,
                                     logger: logger,
                                     viewFactory: viewFactory)
        let toolkitHostingController = ContainerUIHostingController(rootView: rootView,
                                                                    callComposite: self)
        toolkitHostingController.modalPresentationStyle = .fullScreen

        router.setDismissComposite { [weak toolkitHostingController, weak self] in
            toolkitHostingController?.dismissSelf()
            self?.cleanUpManagers()
        }

        return toolkitHostingController
    }

    private func present(_ viewController: UIViewController) {
        DispatchQueue.main.async {
            guard self.isCompositePresentable(),
                  let topViewController = UIWindow.keyWindow?.topViewController else {
                // go to throw the error in the delegate handler
                return
            }
            topViewController.present(viewController, animated: true, completion: nil)
        }
    }

    private func setupColorTheming() {
        let colorProvider = ColorThemeProvider(themeConfiguration: themeConfiguration)
        StyleProvider.color = colorProvider
        DispatchQueue.main.async {
            if let window = UIWindow.keyWindow {
                Colors.setProvider(provider: colorProvider, for: window)
            }
        }
    }

    private func isCompositePresentable() -> Bool {
        guard let keyWindow = UIWindow.keyWindow else {
            return false
        }
        let hasCallComposite = keyWindow.hasViewController(ofKind: ContainerUIHostingController.self)

        return !hasCallComposite
    }

    public func setLocalParticipantPersona(for persona: PersonaData) {
        guard let avatarManager = avatarManager,
              let avatar = persona.avatar else {
            return
        }
        avatarManager.setLocalAvatar(avatar)
    }
    public func setRemoteParticipantsPersona(for identifier: String, persona: PersonaData) { }

}
