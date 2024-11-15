//
//  SidebarButton.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-27.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

struct PageAltMode: Identifiable {
    var id: UUID = UUID()
    var name: String
    var icon: String
    var condition: Bool
}

struct SidebarButton: View, Identifiable {
    typealias ActiveIndicator = WidgetLibrary.UI.ActiveIndicator
    @EnvironmentObject public var nav: Navigation
    @AppStorage("GlobalSidebarWidgets.isUpcomingTaskStackShowing") private var isUpcomingTaskStackShowing: Bool = false
    @AppStorage("GlobalSidebarWidgets.isSearchStackShowing") private var isSearching: Bool = false
    public let id: UUID = UUID()
    public var destination: AnyView
    public let pageType: Page
    public var icon: String?
    public var iconAsImage: Image?
    public var iconWhenSelected: String?
    public var iconAsImageWhenSelected: Image?
    public var label: String
    public var sidebar: AnyView?
    public var showLabel: Bool = true
    public var size: ButtonSize? = .large
    public var altMode: PageAltMode? = nil
    @State private var highlighted: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            let button = FancyButton
            switch(size) {
            case .large:
                switch pageType {
                case .dashboard:
                    HStack(alignment: .top, spacing: 0) {
                        if nav.session.eventStatus == .upcoming {
                            ActiveIndicator(colour: .gray, href: .dashboard)
                        } else if nav.session.eventStatus == .imminent {
                            ActiveIndicator(colour: .orange, href: .dashboard)
                        } else if nav.session.eventStatus == .inProgress {
                            ActiveIndicator(colour: .green, href: .dashboard)
                        }

                        button.frame(width: 50, height: 50)
                    }
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
                        button
                            .frame(width: 50, height: 50)
                        // Log job change events to the CLI/History
                            .onChange(of: nav.session.job) {
                                // Create a history item (used by CLI mode and, eventually, LogTable)
                                if nav.session.cli.history.count <= CommandLineInterface.maxItems {
                                    if let job = nav.session.job {
                                        nav.session.cli.history.append(
                                            Navigation.CommandLineSession.History(
                                                command: "@session.job=\(job.jid.string)",
                                                status: .success,
                                                message: "",
                                                appType: .set,
                                                job: nav.session.job
                                            )
                                        )
                                    }
                                }
                            }
                        //                        .foregroundStyle(nav.session.job != nil ? nav.session.job!.backgroundColor : isDatePickerPresented && nav.parent == pageType ? .black : highlighted ? .white : .white.opacity(0.8))
                            .foregroundStyle(self.highlighted ? .white : .white.opacity(0.8))
                    }
                case .companies:
                    HStack(alignment: .top, spacing: 0) {
                        if let stored = self.nav.session.company {
                            ActiveIndicator(colour: stored.backgroundColor, href: .companies)
                        }
                        button.frame(width: 50, height: 50)
                        //                        .foregroundStyle(nav.session.job != nil ? nav.session.job!.backgroundColor : isDatePickerPresented && nav.parent == pageType ? .black : highlighted ? .white : .white.opacity(0.8))
                            .foregroundStyle(self.highlighted ? self.nav.theme.tint : .white.opacity(0.8))
                    }
                case .projects:
                    HStack(alignment: .top, spacing: 0) {
                        if let stored = self.nav.session.project {
                            ActiveIndicator(colour: stored.backgroundColor, href: .projects)
                        }
                        button.frame(width: 50, height: 50)
                        //                        .foregroundStyle(nav.session.job != nil ? nav.session.job!.backgroundColor : isDatePickerPresented && nav.parent == pageType ? .black : highlighted ? .white : .white.opacity(0.8))
                            .foregroundStyle(self.highlighted ? self.nav.theme.tint : .white.opacity(0.8))
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
        .clipShape(.rect(topLeadingRadius: 5, bottomLeadingRadius: 5))
    }

    private var FancyLink: some View {
        NavigationLink {
            self.destination
        } label: {
            ZStack {
                highlighted ? backgroundColour.opacity(0.9) : backgroundColour.opacity(1)

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

                if let img = self.iconAsImage {
                    img
                        .font(.title)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(self.nav.parent == self.pageType ? self.nav.theme.tint : .white)
                } else {
                    Image(systemName: (altMode != nil ? (altMode!.condition ? altMode!.icon : icon!) : icon!))
                        .font(.title)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(self.nav.parent == self.pageType ? self.nav.theme.tint : .white)
                }

            }
        }
        .help(label)
        .buttonStyle(.plain)
        .useDefaultHover({ hover in highlighted = hover})
    }

    private var FancyButton: some View {
        Button(action: {
            if self.pageType == .planning {
                self.isUpcomingTaskStackShowing = false
            }
            if self.pageType == .dashboard {
                self.isSearching = false
            }
            self.nav.session.appPage = pageType.appPage
            self.nav.to(pageType)
        }, label: {
            ZStack {
                highlighted ? backgroundColour.opacity(0.9) : backgroundColour.opacity(1)

                if nav.parent != pageType && self.nav.parent?.parentView != self.pageType {
                    HStack {
                        Spacer()
                        LinearGradient(gradient: Gradient(colors: [.clear, Theme.base]), startPoint: .leading, endPoint: .trailing)
                            .opacity(0.6)
                            .blendMode(.softLight)
                            .frame(width: 12)
                    }
                } else {
                    LinearGradient(
                        colors: [(highlighted ? Theme.base : .clear), Theme.toolbarColour],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                    .blendMode(.softLight)
                    .opacity(0.3)
                }

                if let img = self.iconAsImage {
                    img
                        .font(.title)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(self.nav.parent == self.pageType || self.nav.parent?.parentView == self.pageType ? self.nav.theme.tint : .white)
                } else {
                    Image(systemName: altMode != nil ? (altMode!.condition ? altMode!.icon : icon!) : icon!)
                        .font(.title)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(self.nav.parent == self.pageType || self.nav.parent?.parentView == self.pageType ? self.nav.theme.tint : .white)
                }
            }
        })
        .help(label)
        .buttonStyle(.plain)
        .useDefaultHover({ hover in highlighted = hover})
    }

    @ViewBuilder private var backgroundColour: some View {
        Theme.toolbarColour
        if nav.parent == pageType || self.nav.parent?.parentView == self.pageType {
            if let parent = nav.parent {
                parent.colour
            } else {
                Theme.tabActiveColour
            }
        } else {
            Theme.tabColour
        }
        if self.highlighted {
            self.pageType.colour
        }
    }
}
