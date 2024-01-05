//
//  FancySimpleButton.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-31.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct FancySimpleButton: View {
    public var text: String
    public var action: (() -> Void)?
    public var icon: String = "checkmark.circle"
    public var showLabel: Bool = true
    public var showIcon: Bool = false
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

            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if let href = href {
                    nav.to(href)
                }
            }
        } label: {
            VStack(alignment: .center) {
                HStack(alignment: .top, spacing: 5) {
                    if showIcon {
                        VStack(alignment: .leading) {
                            Image(systemName: icon)
                                .padding(size.padding)
                        }
                    }

                    if showLabel {
                        VStack(alignment: .leading) {
                            Text(text)
                                .font(.title3)
                                .padding(size.padding)
                        }
                    }
                }
                .font(.title3)
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
