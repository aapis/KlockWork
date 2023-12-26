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
    @State public var tab: TodayViewTab
    @State public var highlighted: Bool = false
    
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        Button(action: {nav.session.toolbar.selected = tab}, label: {
            ZStack {
                Theme.toolbarColour

                if nav.session.toolbar.selected.id == tab.id {
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
                    .foregroundColor(highlighted || nav.session.toolbar.selected.id == tab.id ? .white : .white.opacity(0.8))
            }
        })
        .buttonStyle(.borderless)
        .foregroundColor(Color.white)
        .help(tab.help)
        .frame(width: 50)
        .useDefaultHover({ inside in highlighted = inside})
    }
}
