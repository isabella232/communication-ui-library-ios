//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

class ContainerUIHostingController: UIHostingController<ContainerUIHostingController.Root> {
    class EnvironmentProperty {
        @Published var supportedOrientations: UIInterfaceOrientationMask
        @Published var isProximitySensorOn: Bool
        @Published var prefersHomeIndicatorAutoHidden: Bool

        init() {
            self.supportedOrientations = .portrait
            self.isProximitySensorOn = false
            self.prefersHomeIndicatorAutoHidden = false
        }
    }

    private let callComposite: CallComposite
    private let environmentProperties: EnvironmentProperty
    private let cancelBag = CancelBag()

    init(rootView: ContainerView,
         callComposite: CallComposite,
         isRightToLeft: Bool) {
        let environmentProperties = EnvironmentProperty()
        let environmentRoot = Root(containerView: rootView,
                                   environmentProperties: environmentProperties)
        self.callComposite = callComposite
        self.environmentProperties = environmentProperties
        super.init(rootView: environmentRoot)
        UIView.appearance().semanticContentAttribute = isRightToLeft ?
            .forceRightToLeft : .forceLeftToRight
        subscribeEnvironmentProperties(containerView: rootView)
        haltSetupViewOrientation(containerView: rootView)
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        resetUIDeviceSetup()
        super.viewDidDisappear(animated)
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        self.environmentProperties.supportedOrientations
    }

    private func subscribeEnvironmentProperties(containerView: ContainerView) {
        environmentProperties
            .$supportedOrientations
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink(receiveValue: { _ in
                switch containerView.router.currentView {
                case .setupView:
                    if UIDevice.current.isGeneratingDeviceOrientationNotifications {
                        UIDevice.current.endGeneratingDeviceOrientationNotifications()
                    }
                default:
                    if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
                        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
                    }
                }
            }).store(in: cancelBag)

        environmentProperties
            .$isProximitySensorOn
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink(receiveValue: { isEnable in
                UIDevice.current.toggleProximityMonitoringStatus(isEnabled: isEnable)
            }).store(in: cancelBag)

        environmentProperties
            .$prefersHomeIndicatorAutoHidden
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] shouldHide in
                guard let strongSelf = self else {
                    return
                }
                strongSelf._prefersHomeIndicatorAutoHidden = shouldHide
            }).store(in: cancelBag)
    }

    private func haltSetupViewOrientation(containerView: ContainerView) {
        if containerView.router.currentView == .setupView,
           UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
    }

    private func resetUIDeviceSetup() {
        UIApplication.shared.isIdleTimerDisabled = false
        UIDevice.current.toggleProximityMonitoringStatus(isEnabled: false)

        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
    }

    struct Root: View {
        let containerView: ContainerView
        let environmentProperties: EnvironmentProperty

        var body: some View {
            containerView
                .onPreferenceChange(SupportedOrientationsPreferenceKey.self) {
                    // Update the binding to set the value on the root controller.
                    self.environmentProperties.supportedOrientations = $0
                }
                .onPreferenceChange(ProximitySensorPreferenceKey.self) {
                    self.environmentProperties.isProximitySensorOn = $0
                }
                .onPreferenceChange(PrefersHomeIndicatorAutoHiddenPreferenceKey.self) {
                    self.environmentProperties.prefersHomeIndicatorAutoHidden = $0
                }
        }
    }

    // MARK: Prefers Home Indicator Auto Hidden

    private var _prefersHomeIndicatorAutoHidden: Bool = false {
        didSet { setNeedsUpdateOfHomeIndicatorAutoHidden() }
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        _prefersHomeIndicatorAutoHidden
    }
}
