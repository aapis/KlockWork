//
//  FancyButton.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-07.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

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
    
    private func onAppear() -> Void {
        // @TODO: remove this shit wow
        switch size {
        case .small, .link, .tiny, .tinyLink:
            padding = 0
        case .medium:
            padding = 5
        case .large, .titleLink:
            padding = 10
        }
    }
}

struct FancyButtonv2: View {
    @EnvironmentObject public var nav: Navigation
    public var text: String
    public var action: (() -> Void)?
    public var icon: String? = "checkmark.circle"
    public var iconAsImage: Image? = nil
    public var iconWhenHighlighted: String?
    public var iconAsImageWhenHighlighted: Image? = nil
    public var iconFgColour: Color?
    public var fgColour: Color?
    public var bgColour: Color?
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
    @State private var padding: CGFloat = 10
    @State private var highlighted: Bool = false
    @State private var active: Bool = false

    var body: some View {
        if let destination = redirect {
            Button(action: {
                if let ac = action {
                    ac()
                }
                
                nav.setView(destination)

                if self.sidebar != nil {
                    nav.setSidebar(sidebar!)
                }

                nav.setId()

                if let pType = pageType {
                    nav.setParent(pType)
                }
            }) {
                button
            }
            .buttonStyle(.plain)
            .useDefaultHover({ inside in highlighted = inside})
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
            .useDefaultHover({ inside in highlighted = inside})
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
                    if let icon = self.icon {
                        Image(systemName: self.highlighted && self.iconWhenHighlighted != nil ? self.iconWhenHighlighted! : icon)
                            .symbolRenderingMode(.hierarchical)
                            .font(.title)
                            .foregroundStyle(self.iconFgColour ?? self.fgColour ?? .white)
                    } else if let ic = self.iconAsImage {
                        AnyView(self.highlighted && self.iconAsImageWhenHighlighted != nil ? self.iconAsImageWhenHighlighted!: ic)
                            .symbolRenderingMode(.hierarchical)
                            .font(.title)
                            .foregroundStyle(self.iconFgColour ?? self.fgColour ?? .white)
                    }
                }

                if showLabel! {
                    Text(text)
                }
            }
            .padding(size.padding)
        }
        .frame(maxWidth: buttonFrameWidth(), maxHeight: size.height)
        .foregroundStyle(self.fgColour ?? (highlighted ? type.highlightColour : type.textColour))
        .font(size.font)
        .help(text)
        .underline((size == .link || size == .titleLink) && highlighted)
    }

    private var Background: some View {
        ZStack {
            bgColour ?? type.colours.first
        }
        .mask(
            RoundedRectangle(cornerRadius: 3)
        )
    }

    private var HighlightedBackground: some View {
        ZStack {
            bgColour ?? type.colours.first
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
            bgColour ?? type.activeColour
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
        if let showingLabel = showLabel {
            if showingLabel && size != .link {
                return 200
            }
        }

        return size.width
    }

    private func fgColourEffect() -> Color {
//        let gradient = LinearGradient(colors: [fgColour, Color.black])
        return Theme.base
    }
}
