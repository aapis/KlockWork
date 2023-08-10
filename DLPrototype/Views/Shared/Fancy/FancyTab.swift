//
//  FancyTab.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-05-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct FancyTab: View {
    @State public var tab: Tab
    @State public var highlighted: Bool = false

    @Binding public var selected: Int

    var body: some View {
        Button(action: {setActive(tab.id)}, label: {
            ZStack {
                Theme.toolbarColour

                if selected == tab.id {
                    Theme.tabActiveColour
                } else {
                    Theme.tabColour
                    VStack {
                        Spacer()
                        LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom)
                            .opacity(0.6)
                            .blendMode(.softLight)
                            .frame(height: 12)
                    }
                }
                Image(systemName: tab.icon)
                    .foregroundColor(highlighted || selected == tab.id ? .white : .white.opacity(0.8))
            }
        })
        .buttonStyle(.borderless)
        .foregroundColor(Color.white)
        .help(tab.help)
        .frame(width: 50)
        .useDefaultHover({ inside in highlighted = inside})
    }
}

extension FancyTab {
    private func setActive(_ index: Int) -> Void {
        selected = index
    }
}
