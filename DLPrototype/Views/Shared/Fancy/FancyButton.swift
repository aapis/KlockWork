//
//  FancyButton.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-07.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct FancyButton: View {
    public var text: String
    public var action: () -> Void
    public var icon: String? = "checkmark.circle"
    public var altIcon: String? = "checkmark.circle"
    public var transparent: Bool? = false
    public var showLabel: Bool? = true
    public var showIcon: Bool? = true
    public var fgColour: Color?
    public var size: ButtonSize = .medium
    
    @State private var padding: CGFloat = 10
    
    var body: some View {
        VStack {
            Button(action: action, label: {
                HStack {
                    if showIcon! {
                        Image(systemName: icon!)
                            .foregroundColor(fgColour != nil ? fgColour : .white)
                    }
                    
                    if showLabel! {
                        Text(text)
                    }
                }
                .foregroundColor(Color.white)
                .font(.title3)
                .padding(padding)
                .help(text)
                .onHover { inside in
                    if inside {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            })
            .buttonStyle(.borderless)
            .background(transparent! ? Color.clear : Color.black.opacity(0.2))
            .onAppear(perform: onAppear)
        }
    }
    
    private func onAppear() -> Void {
        switch size {
        case .small, .link, .tiny:
            padding = 0
        case .medium:
            padding = 5
        case .large, .titleLink:
            padding = 10
        }
    }
}

public struct FancyButtonv2: View {
    public var text: String
    public var action: (() -> Void)?
    public var icon: String? = "checkmark.circle"
    public var fgColour: Color?
    public var highlightColour: Color?
    public var transparent: Bool? = false
    public var showLabel: Bool? = true
    public var showIcon: Bool? = true
    public var size: ButtonSize = .small
    public var type: ButtonType = .standard
    public var redirect: AnyView? = nil
    public var pageType: Page? = nil
    public var sidebar: AnyView? = nil
    public var twoStage: Bool = false

    @EnvironmentObject public var nav: Navigation

    @State private var padding: CGFloat = 10
    @State private var highlighted: Bool = false
    @State private var active: Bool = false

    public var body: some View {
        VStack {
            if let destination = redirect {
                Button(action: {
                    if let ac = action {
                        ac()
                    }

                    nav.view = destination
                    nav.sidebar = sidebar
                    nav.pageId = UUID()

                    if let pType = pageType {
                        nav.parent = pType
                    }
                }) {
                    button
                }
                .buttonStyle(.plain)
            } else {
                Button(action: {
                    if let ac = action {
                        ac()
                    }

                    if twoStage {
                        active.toggle()
                    }
                }) {
                    button
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var button: some View {
        ZStack(alignment: [.link, .titleLink].contains(size) ? .topLeading : .center) {
            if ![.link, .titleLink].contains(size)  {
                if active {
                    ActiveBackground
                } else {
                    if highlighted {
                        if let highlightColour = highlightColour {
                            ZStack {
                                highlightColour
                            }
                            .mask(
                                RoundedRectangle(cornerRadius: 3)
                            )
                        } else {
                            HighlightedBackground
                        }
                    } else {
                        Background
                    }
                }
            } else {
                Color.clear
            }

            HStack {
                if showIcon! {
                    Image(systemName: icon!)
                        .symbolRenderingMode(.hierarchical)
                        .font(.title2)
                }

                if showLabel! {
                    Text(text)
                }
            }
            .padding(size.padding)
        }
        .frame(maxWidth: buttonFrameWidth(), maxHeight: size.height)
        .foregroundColor(fgColour == nil ? (highlighted ? type.highlightColour : type.textColour) : fgColour)
        .font(size.font)
        .help(text)
        .underline((size == .link || size == .titleLink) && highlighted)
        .useDefaultHover({ inside in highlighted = inside})
    }

    private var Background: some View {
        ZStack {
            type.colours.first
        }
        .mask(
            RoundedRectangle(cornerRadius: 3)
        )
    }

    private var HighlightedBackground: some View {
        ZStack {
            type.colours.first
            LinearGradient(gradient: Gradient(colors: type.colours), startPoint: .top, endPoint: .bottom)
                .blendMode(.softLight)
                .opacity(0.3)
        }
        .mask(
            RoundedRectangle(cornerRadius: 3)
        )
    }

    private var ActiveBackground: some View {
        ZStack {
            type.activeColour
            LinearGradient(gradient: Gradient(colors: [type.activeColour, .black]), startPoint: .top, endPoint: .bottom)
                .blendMode(.softLight)
                .opacity(0.3)
        }
        .mask(
            RoundedRectangle(cornerRadius: 3)
        )
    }
}

extension FancyButtonv2 {
    private func buttonFrameWidth() -> CGFloat {
        if showLabel! {
            return 200
        }

        return size.width
    }

    private func fgColourEffect() -> Color {
//        let gradient = LinearGradient(colors: [fgColour, Color.black])
        return Color.black
    }
}
