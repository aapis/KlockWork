//
//  SidebarButton.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-27.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct SidebarButton: View, Identifiable {
    public let id: UUID = UUID()
    public var destination: AnyView
    public let pageType: Page
    public var icon: String
    public var label: String
    public var sidebar: AnyView?
    public var showLabel: Bool = true
    public var size: ButtonSize? = .large

    @State private var highlighted: Bool = false

    @EnvironmentObject public var nav: Navigation

    @AppStorage("isDatePickerPresented") public var isDatePickerPresented: Bool = false

    var body: some View {
        let button = FancyButton
        switch(size) {
        case .large:
            switch pageType {
            case .planning:
                HStack(alignment: .top, spacing: 0) {
                    if nav.session.gif == .focus {
                        ActiveIndicator(href: .planning)
                    }
                    button.frame(width: 50, height: 50)
                }
            case .jobs:
                HStack(alignment: .top, spacing: 0) {
                    if nav.session.job != nil {
                        ActiveIndicator(colour: nav.session.job!.colour_from_stored(), href: .jobs)
                    }
                    button.frame(width: 50, height: 50)
                }
            default: button.frame(width: 50, height: 50)
            }
        case .medium:
            button.frame(width: 40, height: 40)
        case .small:
            button.frame(width: 20, height: 20)
        case .link, .tiny, .titleLink, .tinyLink, .none:
            button
        }
    }

    private var FancyButton: some View {
        Button(action: {
            if isDatePickerPresented {
                isDatePickerPresented = false
            }

            nav.to(pageType)
        }, label: {
            ZStack {
                backgroundColour

                if nav.parent != pageType {
                    HStack {
                        Spacer()
                        LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .leading, endPoint: .trailing)
                            .opacity(0.6)
                            .blendMode(.softLight)
                            .frame(width: 12)
                    }
                } else {
                    LinearGradient(
                        colors: [(highlighted ? .black : .clear), Theme.toolbarColour],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                    .opacity(0.1)
                }

                Image(systemName: isDatePickerPresented && nav.parent == pageType ? "xmark" : icon)
                    .font(.title)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(isDatePickerPresented && nav.parent == pageType ? .black : highlighted ? .white : .white.opacity(0.8))
            }
        })
        .help(label)
        .buttonStyle(.plain)
        .onHover { inside in
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }

            highlighted.toggle()
        }
    }

    @ViewBuilder private var backgroundColour: some View {
        Theme.toolbarColour
        if nav.parent == pageType {
            if let parent = nav.parent {
                if isDatePickerPresented {
//                    Theme.secondary
                    Color.white
                } else {
                    parent.colour
                }
            } else {
                Theme.tabActiveColour
            }
        } else {
            Theme.tabColour
        }
    }

    struct ActiveIndicator: View {
        public var colour: Color = .white
        public var action: (() -> Void)? = nil
        public var href: Page? = nil

        @EnvironmentObject private var nav: Navigation

        var body: some View {
            Button {
                if let callback = action {
                    callback()
                } else {
                    if let href = href {
                        nav.to(href)
                    }
                }
            } label: {
                ZStack {
                    Theme.base
                    colour
                }
            }
            .buttonStyle(.borderless)
            .frame(width: 6, height: 50)
        }
    }
}
