//
//  FancyGenericToolbar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

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
    public var showIcon: Bool = true
    public var showLabel: Bool = true

    init(id: Int, helpText: String, label: AnyView?, contents: AnyView?, showIcon: Bool = true, showLabel: Bool = true) {
        self.id = id
        self.helpText = helpText
        self.label = label
        self.contents = contents
        self.showIcon = showIcon
        self.showLabel = showLabel
    }

    init(id: Int, helpText: String, icon: String, labelText: String, contents: AnyView?, showIcon: Bool = true, showLabel: Bool = true) {
        self.id = id
        self.helpText = helpText
        self.icon = AnyView(Image(systemName: icon).symbolRenderingMode(.hierarchical).font(.title2))
        self.label = AnyView(
            HStack {
                self.icon
                Text(labelText)
            }
        )
        self.labelText = labelText
        self.contents = contents
        self.showIcon = showIcon
        self.showLabel = showLabel
    }

    init(id: Int, helpText: String, icon: Image, labelText: String, contents: AnyView?, showIcon: Bool = true, showLabel: Bool = true) {
        self.id = id
        self.helpText = helpText
        self.icon = AnyView(icon.symbolRenderingMode(.hierarchical).font(.title2))
        self.label = AnyView(
            HStack {
                self.icon
                Text(labelText)
            }
        )
        self.labelText = labelText
        self.contents = contents
        self.showIcon = showIcon
        self.showLabel = showLabel
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
    public var page: PageConfiguration.AppPage?
    public var alwaysShowTab: Bool = false
    @State public var selected: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            if self.alwaysShowTab == true || buttons.count > 1 {
                GridRow {
                    Group {
                        ZStack(alignment: .bottom) {
                            (self.location == .content ? UIGradient() : nil)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 1) {
                                    ForEach(self.buttons.sorted(by: {$0.id < $1.id}), id: \ToolbarButton.id) { button in
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
                                .clipShape(.rect(topLeadingRadius: self.location == .content ? 5 : 0, topTrailingRadius: self.location == .content ? 5 : 0))
                            }
                        }
                    }
                }
                .frame(height: self.location == .content ? 50 : 32)
            }

            GridRow {
                Group {
                    ZStack(alignment: .leading) {
                        if !standalone {
                            Theme.textBackground
                        }

                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(buttons, id: \ToolbarButton.id) { button in
                                    if button.id == selected && button.contents != nil {
                                        button.contents
                                            .clipShape(.rect(bottomLeadingRadius: self.location == .content ? 5 : 0, bottomTrailingRadius: self.location == .content ? 5 : 0))
                                    }
                                }
                            }
                            .clipShape(.rect(topLeadingRadius: self.location == .content && self.buttons.count == 0 ? 5 : 0, topTrailingRadius: self.location == .content ? 5 : 0))
                        }
                        .padding(standalone ? 0 : 20)
                    }
                }
            }
        }
        .clipShape(.rect(cornerRadius: 5))
    }

    struct TabView: View {
        @EnvironmentObject public var nav: Navigation
        @AppStorage("settings.accessibility.showTabTitles") private var showTabTitles: Bool = true
        public var button: ToolbarButton
        public var location: WidgetLocation
        @Binding public var selected: Int
        public var mode: ToolbarMode
        public var page: PageConfiguration.AppPage?
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
                        (
                            selected == button.id ?
                            (
                                location == .sidebar ? Theme.base.opacity(0.2) : self.page != nil ? self.page!.primaryColour : self.nav.theme.tint.opacity(0.8)
                            )
                            :
                            (
                                highlighted ? Theme.tabColour.opacity(0.6) : Theme.base.opacity(0.1)
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
                            if self.button.showIcon {
                                button.icon
                                    .padding(0)
                                    .foregroundStyle(self.selected == self.button.id ? self.nav.session.job?.backgroundColor ?? .white : .white.opacity(0.5))
                            }
                        } else {
                            if self.showTabTitles && self.button.showLabel {
                                button.label
                                    .padding(0)
                                    .foregroundStyle(self.selected == self.button.id ? .white : .white.opacity(0.5))
                            }
                        }
                    } else {
                        if mode == .compact {
                            HStack(alignment: .center, spacing: 8) {
                                if self.button.showIcon {
                                    self.button.icon
                                        .foregroundStyle(self.selected == self.button.id ? self.nav.session.job?.backgroundColor ?? .white : .white.opacity(0.5))
                                        .font(.title3)
                                }

                                if self.selected == self.button.id && self.button.labelText != nil && self.showTabTitles {
                                    Text(self.button.labelText!)
                                        .foregroundStyle(self.selected == self.button.id ? .white : .white.opacity(0.5))
                                        .font(.headline)
                                }
                            }
                            .padding([.top, .bottom], 10)
                            .padding([.leading, .trailing])
                        } else {
                            if self.showTabTitles && self.button.showLabel {
                                self.button.label.padding(16)
                                    .foregroundStyle(self.selected == self.button.id ? .white : .white.opacity(0.5))
                            } else {
                                if self.button.showIcon {
                                    self.button.icon
                                        .foregroundStyle(self.selected == self.button.id ? self.nav.session.job?.backgroundColor ?? .white : .white.opacity(0.5))
                                        .font(.title3)
                                        .padding([.top, .bottom], 10)
                                        .padding([.leading, .trailing])
                                }
                            }
                        }
                    }
                }
            }
            .clipShape(
                .rect(
                    topLeadingRadius: self.selected == self.button.id || self.highlighted ? 5 : 0,
                    topTrailingRadius: self.selected == self.button.id || self.highlighted ? 5 : 0
                )
            )
            .buttonStyle(.plain)
            .help(button.helpText)
            .useDefaultHover({ hover in highlighted = hover})
        }
    }

    struct UIGradient: View {
        public var reverse: Bool = false

        var body: some View {
            LinearGradient(gradient: Gradient(colors: [.clear, Theme.base]), startPoint: self.reverse ? .bottom : .top, endPoint: self.reverse ? .top : .bottom)
                .opacity(0.2)
                .blendMode(.softLight)
                .frame(height: 12)
        }
    }

    struct ActionButton: View {
        @EnvironmentObject public var state: Navigation
        public var icon: String?
        public var iconAsImage: Image?
        public var callback: () -> Void
        public var helpText: String

        var body: some View {
            Button {
                self.callback()
            } label: {
                if let icon = self.icon {
                    Image(systemName: icon)
                } else if let icon = self.iconAsImage {
                    icon
                }
            }
            .buttonStyle(.plain)
            .help(self.helpText)
            .foregroundStyle(self.state.theme.tint)
            .padding(3)
            .background(Theme.textBackground)
            .clipShape(.rect(cornerRadius: 5))
        }
    }
}

extension FancyGenericToolbar.TabView {
    private func setActive(_ button: ToolbarButton) -> Void {
        selected = button.id
        self.nav.setInspector()
    }
}
