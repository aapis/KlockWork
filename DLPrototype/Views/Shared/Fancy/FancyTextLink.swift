//
//  FancyTextLink.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct FancyTextLink: View {
    @EnvironmentObject public var nav: Navigation
    public var text: String
    public var transparent: Bool? = true
    public var showIcon: Bool? = false
    public var destination: AnyView?
    public var fgColour: Color? = Color.white
    public var bgColour: Color? = Color.black.opacity(0.2)
    public var pageType: Page = .today
    public var sidebar: AnyView? = nil
    @State private var highlighted: Bool = false

    var body: some View {
        VStack {
            Button {
                nav.setView(destination!)
                nav.setParent(pageType)
                nav.setSidebar(sidebar!)
                nav.setId()
            } label: {
                if showIcon! {
                    Image(systemName: "link")
                }
                
                Text(text)
                    .font(Theme.font)
                    .multilineTextAlignment(.leading)
            }
            .buttonStyle(.borderless)
            .foregroundColor(fgColour)
            .font(.title3)
            .underline()
            .background(transparent! ? Color.clear : bgColour)
            .useDefaultHover({ inside in self.highlighted = inside})
        }
    }
}
