//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI

protocol CompositeViewModelFactory {
    // MARK: CompositeViewModels
    func getSetupViewModel() -> SetupViewModel
    func getCallingViewModel() -> CallingViewModel

    // MARK: ComponentViewModels
    func makeIconButtonViewModel(iconName: CompositeIcon,
                                 buttonType: IconButtonViewModel.ButtonType,
                                 isDisabled: Bool,
                                 action: @escaping (() -> Void)) -> IconButtonViewModel
    func makeIconWithLabelButtonViewModel(iconName: CompositeIcon,
                                          buttonTypeColor: IconWithLabelButtonViewModel.ButtonTypeColor,
                                          buttonLabel: String,
                                          isDisabled: Bool,
                                          action: @escaping (() -> Void)) -> IconWithLabelButtonViewModel
    func makeLocalVideoViewModel(dispatchAction: @escaping ActionDispatch) -> LocalVideoViewModel
    func makePrimaryButtonViewModel(buttonStyle: FluentUI.ButtonStyle,
                                    buttonLabel: String,
                                    iconName: CompositeIcon?,
                                    isDisabled: Bool,
                                    action: @escaping (() -> Void)) -> PrimaryButtonViewModel
    func makeAudioDevicesListViewModel(dispatchAction: @escaping ActionDispatch,
                                       localUserState: LocalUserState) -> AudioDevicesListViewModel
    func makeErrorInfoViewModel() -> ErrorInfoViewModel

    // MARK: CallingViewModels
    func makeLobbyOverlayViewModel() -> LobbyOverlayViewModel
    func makeControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                 endCallConfirm: @escaping (() -> Void),
                                 localUserState: LocalUserState) -> ControlBarViewModel
    func makeInfoHeaderViewModel(localUserState: LocalUserState) -> InfoHeaderViewModel
    func makeParticipantCellViewModel(participantModel: ParticipantInfoModel) -> ParticipantGridCellViewModel
    func makeParticipantGridsViewModel() -> ParticipantGridViewModel
    func makeParticipantsListViewModel(localUserState: LocalUserState) -> ParticipantsListViewModel
    func makeBannerViewModel() -> BannerViewModel
    func makeBannerTextViewModel() -> BannerTextViewModel

    // MARK: SetupViewModels
    func makePreviewAreaViewModel(dispatchAction: @escaping ActionDispatch) -> PreviewAreaViewModel
    func makeSetupControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                      localUserState: LocalUserState) -> SetupControlBarViewModel
    func makeJoiningCallActivityViewModel() -> JoiningCallActivityViewModel
}

class ACSCompositeViewModelFactory: CompositeViewModelFactory {
    private let logger: Logger
    private let store: Store<AppState>
    private let accessibilityProvider: AccessibilityProvider
    private let localizationProvider: LocalizationProvider

    private weak var setupViewModel: SetupViewModel?
    private weak var callingViewModel: CallingViewModel?

    init(logger: Logger,
         store: Store<AppState>,
         localizationProvider: LocalizationProvider,
         accessibilityProvider: AccessibilityProvider) {
        self.logger = logger
        self.store = store
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider
    }

    // MARK: CompositeViewModels
    func getSetupViewModel() -> SetupViewModel {
        guard let viewModel = self.setupViewModel else {
            let viewModel = SetupViewModel(compositeViewModelFactory: self,
                                           logger: logger,
                                           store: store,
                                           localizationProvider: localizationProvider)
            self.setupViewModel = viewModel
            self.callingViewModel = nil
            return viewModel
        }
        return viewModel
    }

    func getCallingViewModel() -> CallingViewModel {
        guard let viewModel = self.callingViewModel else {
            let viewModel = CallingViewModel(compositeViewModelFactory: self,
                                             logger: logger,
                                             store: store,
                                             localizationProvider: localizationProvider,
                                             accessibilityProvider: accessibilityProvider)
            self.setupViewModel = nil
            self.callingViewModel = viewModel
            return viewModel
        }
        return viewModel
    }

    // MARK: ComponentViewModels
    func makeIconButtonViewModel(iconName: CompositeIcon,
                                 buttonType: IconButtonViewModel.ButtonType = .controlButton,
                                 isDisabled: Bool,
                                 action: @escaping (() -> Void)) -> IconButtonViewModel {
        IconButtonViewModel(iconName: iconName,
                            buttonType: buttonType,
                            isDisabled: isDisabled,
                            action: action)
    }
    func makeIconWithLabelButtonViewModel(iconName: CompositeIcon,
                                          buttonTypeColor: IconWithLabelButtonViewModel.ButtonTypeColor,
                                          buttonLabel: String,
                                          isDisabled: Bool,
                                          action: @escaping (() -> Void)) -> IconWithLabelButtonViewModel {
        IconWithLabelButtonViewModel(iconName: iconName,
                                     buttonTypeColor: buttonTypeColor,
                                     buttonLabel: buttonLabel,
                                     isDisabled: isDisabled,
                                     action: action)
    }
    func makeLocalVideoViewModel(dispatchAction: @escaping ActionDispatch) -> LocalVideoViewModel {
        LocalVideoViewModel(compositeViewModelFactory: self,
                            logger: logger,
                            localizationProvider: localizationProvider,
                            dispatchAction: dispatchAction)
    }
    func makePrimaryButtonViewModel(buttonStyle: FluentUI.ButtonStyle,
                                    buttonLabel: String,
                                    iconName: CompositeIcon?,
                                    isDisabled: Bool = false,
                                    action: @escaping (() -> Void)) -> PrimaryButtonViewModel {
        PrimaryButtonViewModel(buttonStyle: buttonStyle,
                               buttonLabel: buttonLabel,
                               iconName: iconName,
                               isDisabled: isDisabled,
                               action: action)
    }
    func makeAudioDevicesListViewModel(dispatchAction: @escaping ActionDispatch,
                                       localUserState: LocalUserState) -> AudioDevicesListViewModel {
        AudioDevicesListViewModel(dispatchAction: dispatchAction,
                                  localUserState: localUserState,
                                  localizationProvider: localizationProvider)
    }
    func makeErrorInfoViewModel() -> ErrorInfoViewModel {
        ErrorInfoViewModel(localizationProvider: localizationProvider)
    }

    // MARK: CallingViewModels
    func makeLobbyOverlayViewModel() -> LobbyOverlayViewModel {
        return LobbyOverlayViewModel(localizationProvider: localizationProvider)
    }
    func makeControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                 endCallConfirm: @escaping (() -> Void),
                                 localUserState: LocalUserState) -> ControlBarViewModel {
        ControlBarViewModel(compositeViewModelFactory: self,
                            logger: logger,
                            localizationProvider: localizationProvider,
                            dispatchAction: dispatchAction,
                            endCallConfirm: endCallConfirm,
                            localUserState: localUserState)
    }
    func makeInfoHeaderViewModel(localUserState: LocalUserState) -> InfoHeaderViewModel {
        InfoHeaderViewModel(compositeViewModelFactory: self,
                            logger: logger,
                            localUserState: localUserState,
                            localizationProvider: localizationProvider,
                            accessibilityProvider: accessibilityProvider)
    }

    func makeParticipantCellViewModel(participantModel: ParticipantInfoModel) -> ParticipantGridCellViewModel {
        ParticipantGridCellViewModel(compositeViewModelFactory: self, participantModel: participantModel)
    }
    func makeParticipantGridsViewModel() -> ParticipantGridViewModel {
        ParticipantGridViewModel(compositeViewModelFactory: self,
                                 localizationProvider: localizationProvider,
                                 accessibilityProvider: accessibilityProvider)
    }

    func makeParticipantsListViewModel(localUserState: LocalUserState) -> ParticipantsListViewModel {
        ParticipantsListViewModel(localUserState: localUserState,
                                  localizationProvider: localizationProvider)
    }
    func makeBannerViewModel() -> BannerViewModel {
        BannerViewModel(compositeViewModelFactory: self)
    }
    func makeBannerTextViewModel() -> BannerTextViewModel {
        BannerTextViewModel(accessibilityProvider: accessibilityProvider,
                            localizationProvider: localizationProvider)
    }

    // MARK: SetupViewModels
    func makePreviewAreaViewModel(dispatchAction: @escaping ActionDispatch) -> PreviewAreaViewModel {
        PreviewAreaViewModel(compositeViewModelFactory: self,
                             dispatchAction: dispatchAction,
                             localizationProvider: localizationProvider)
    }

    func makeSetupControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                      localUserState: LocalUserState) -> SetupControlBarViewModel {
        SetupControlBarViewModel(compositeViewModelFactory: self,
                                 logger: logger,
                                 dispatchAction: dispatchAction,
                                 localUserState: localUserState,
                                 localizationProvider: localizationProvider)
    }

    func makeJoiningCallActivityViewModel() -> JoiningCallActivityViewModel {
        JoiningCallActivityViewModel(localizationProvider: localizationProvider)
    }
}
