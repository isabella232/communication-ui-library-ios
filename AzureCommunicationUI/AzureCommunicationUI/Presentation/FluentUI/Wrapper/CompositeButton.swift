//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct CompositeButton: UIViewRepresentable {
    let buttonStyle: FluentUI.ButtonStyle
    let buttonLabel: String
    let iconName: CompositeIcon?

    init(buttonStyle: FluentUI.ButtonStyle, buttonLabel: String, iconName: CompositeIcon? = nil) {
        self.buttonStyle = buttonStyle
        self.buttonLabel = buttonLabel
        self.iconName = iconName
    }

    func makeUIView(context: Context) -> FluentUI.Button {
        let button = Button(style: buttonStyle)
        button.setTitle(buttonLabel, for: .normal)
        button.titleLabel?.numberOfLines = 0

        if let iconName = iconName {
            let icon = StyleProvider.icon.getUIImage(for: iconName)
            button.image = icon
        }

        return button
    }

    func updateUIView(_ uiView: FluentUI.Button, context: Context) {
    }
}
