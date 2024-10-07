//
//  FancySimpleButton.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-31.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct FancySimpleButton: View {
    public var text: String
    public var action: (() -> Void)?
    public var icon: String = "checkmark.circle"
    public var showLabel: Bool = true
    public var showIcon: Bool = false
    public var labelView: AnyView? = nil
    public var size: ButtonSize = .large
    public var type: ButtonType = .standard
    public var href: Page? = nil

    @State private var highlighted: Bool = false

    @EnvironmentObject private var nav: Navigation

    var body: some View {
        Button {
            if let action = action {
                action()
            }

            if let href = href {
                nav.to(href)
            }
        } label: {
            if let labelView = labelView {
                labelView
            } else {
                VStack(alignment: .center, spacing: 0) {
                    HStack(alignment: .top, spacing: 5) {
                        if showIcon {
                            Image(systemName: icon)
                                .padding(size.padding)
                        }
                        
                        if showLabel {
                            Text(text)
                                .font(.title3)
                                .padding(size.padding)
                        }
                    }
                    .font(.title3)
                }
            }
        }
        .help(text)
        .buttonStyle(.borderless)
        .background(highlighted ? type.highlightColour : type.colours.first)
        .foregroundColor(type.textColour)
//        .mask(RoundedRectangle(cornerRadius: 3)) // @TODO: make configurable?
        .useDefaultHover({ inside in highlighted = inside})
    }
}
