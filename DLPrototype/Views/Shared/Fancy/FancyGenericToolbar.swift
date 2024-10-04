//
//  FancyGenericToolbar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ToolbarButton: Hashable, Equatable {
    static func == (lhs: ToolbarButton, rhs: ToolbarButton) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var id: Int
    public var helpText: String
    public var icon: AnyView?
    public var label: AnyView?
    public var labelText: String?
    public var contents: AnyView?
    
    init(id: Int, helpText: String, label: AnyView?, contents: AnyView?) {
        self.id = id
        self.helpText = helpText
        self.label = label
        self.contents = contents
    }

    init(id: Int, helpText: String, icon: String, labelText: String, contents: AnyView?) {
        self.id = id
        self.helpText = helpText
        self.icon = AnyView(Image(systemName: icon))
        self.label = AnyView(
            HStack {
                self.icon
                Text(labelText)
            }
        )
        self.labelText = labelText
        self.contents = contents
    }

    init(id: Int, helpText: String, icon: Image, labelText: String, contents: AnyView?) {
        self.id = id
        self.helpText = helpText
        self.icon = AnyView(icon)
        self.label = AnyView(
            HStack {
                self.icon
                Text(labelText)
            }
        )
        self.labelText = labelText
        self.contents = contents
    }
}

enum ToolbarMode {
    case full, compact
}

struct FancyGenericToolbar: View {
    @EnvironmentObject public var nav: Navigation
    public var buttons: [ToolbarButton]
    public var standalone: Bool = false
    public var location: WidgetLocation = .content
    public var mode: ToolbarMode = .full
    public var page: PageConfiguration.AppPage = .today
    @State public var selected: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            GridRow {
                Group {
                    ZStack(alignment: .topLeading) {
                        (location == .sidebar ? .clear : Theme.textBackground)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 1) {
                                ForEach(buttons, id: \ToolbarButton.id) { button in
                                    TabView(
                                        button: button,
                                        location: location,
                                        selected: $selected,
                                        mode: mode,
                                        page: self.page
                                    )

                                    if buttons.count == 1 {
                                        Text(buttons.first!.helpText)
                                            .padding(.leading, 10)
                                            .opacity(0.6)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(height: self.location == .content ? 50 : 32)

            GridRow {
                Group {
                    ZStack(alignment: .leading) {
                        if !standalone {
                            Theme.toolbarColour
                        }

                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(buttons, id: \ToolbarButton.id) { button in
                                    if button.id == selected && button.contents != nil {
                                        button.contents
                                    }
                                }
                            }
                        }
                        .padding(standalone ? 0 : 20)
                    }
                }
            }
        }
    }

    struct TabView: View {
        @EnvironmentObject public var nav: Navigation
        public var button: ToolbarButton
        public var location: WidgetLocation
        @Binding public var selected: Int
        public var mode: ToolbarMode
        public var page: PageConfiguration.AppPage

        @State private var highlighted: Bool = false
        
        var body: some View {
            if location == .sidebar {
                if mode == .compact {
                    ButtonView.frame(width: 40)
                } else {
                    ButtonView
                }
            } else {
                ButtonView
            }
        }

        var ButtonView: some View {
            Button(action: {setActive(button)}) {
                ZStack(alignment: mode == .compact ? .center : .leading) {
                    ZStack(alignment: .bottom) {
                        if selected != button.id {
                            UIGradient()
                        }

                        (
                            selected == button.id ?
                            (
                                location == .sidebar ? Theme.base.opacity(0.2) : self.page.primaryColour
                            )
                            :
                            (
                                highlighted ? Theme.tabColour.opacity(0.6) : Theme.tabColour
                            )
                        )
                    }

                    if selected != button.id && location == .content {
                        VStack {
                            Spacer()
                            UIGradient()
                        }
                    }

                    if location == .sidebar {
                        if mode == .compact {
                            button.icon
                                .padding(0)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(self.selected == self.button.id ? self.nav.session.job?.backgroundColor ?? .white : .white.opacity(0.5))
                        } else {
                            button.label.padding(0)
                                .foregroundStyle(self.selected == self.button.id ? .white : .white.opacity(0.5))
                        }
                    } else {
                        if mode == .compact {
                            HStack(alignment: .center, spacing: 8) {
                                button.icon.symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(self.selected == self.button.id ? self.nav.session.job?.backgroundColor ?? .white : .white.opacity(0.5))

                                if self.selected == self.button.id && self.button.labelText != nil {
                                    Text(self.button.labelText!)
                                        .foregroundStyle(self.selected == self.button.id ? .white : .white.opacity(0.5))
                                }
                            }
                            .font(.headline)
                            .padding([.top, .bottom], 10)
                            .padding([.leading, .trailing])
                        } else {
                            button.label.padding(16)
                                .foregroundStyle(self.selected == self.button.id ? .white : .white.opacity(0.5))
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .help(button.helpText)
            .useDefaultHover({ hover in highlighted = hover})
        }
    }

    struct UIGradient: View {
        public var reverse: Bool = false

        var body: some View {
            LinearGradient(gradient: Gradient(colors: [.clear, Theme.base]), startPoint: self.reverse ? .bottom : .top, endPoint: self.reverse ? .top : .bottom)
                .opacity(0.6)
                .blendMode(.softLight)
                .frame(height: 12)
        }
    }
}

extension FancyGenericToolbar.TabView {
    private func setActive(_ button: ToolbarButton) -> Void {
        selected = button.id
    }
}
