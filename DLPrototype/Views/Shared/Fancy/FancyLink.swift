//
//  FancyLink.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public enum ButtonSize {
    case small, medium, large, link
}

struct FancyLink: View {
    public var icon: String?
    public var showIcon: Bool = true
    public var label: String? = ""
    public var showLabel: Bool = false
    public var colour: Color = Color.clear
    public var fgColour: Color = Color.white
    public var destination: AnyView?
    public var size: ButtonSize = .large
    public var pageType: Page = .dashboard

    @EnvironmentObject public var nav: Navigation
    
    @State private var padding: CGFloat = 10
    @State private var highlighted: Bool = false
    
    var body: some View {
        VStack {
            let button = Button {
                nav.view = destination
                nav.parent = pageType
            } label: {
                if showIcon && icon != nil {
                    Image(systemName: icon!)
                }

                if showLabel && label != nil {
                    Text(label!)
                        .foregroundColor(fgColour)
                        .font(Theme.font)
                }
            }
            .buttonStyle(.borderless)
            .foregroundColor(Color.white)
            .font(.title3)
            .padding(padding)
            .background(highlighted ? .black.opacity(0.3) : colour)
            .onHover { inside in
                if inside {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }

                highlighted.toggle()
            }

            if size == .link {
                button.underline()
            } else {
                button
            }
        }
        .onAppear(perform: onAppear)
    }
    
    private func onAppear() -> Void {
        switch size {
        case .small, .link:
            padding = 0
        case .medium:
            padding = 5
        case .large:
            padding = 10
        }
    }
}
