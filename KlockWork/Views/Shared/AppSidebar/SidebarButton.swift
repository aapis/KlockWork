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
    public let id: UUID = UUID()
    public var destination: AnyView
    public let pageType: Page
    public var icon: String?
    public var iconAsImage: Image?
    public var label: String
    public var sidebar: AnyView?
    public var showLabel: Bool = true
    public var size: ButtonSize? = .large
    public var altMode: PageAltMode? = nil

    @State private var highlighted: Bool = false

    @EnvironmentObject public var nav: Navigation
    @AppStorage("isDatePickerPresented") public var isDatePickerPresented: Bool = false
    @AppStorage("CreateEntitiesWidget.isUpcomingTaskStackShowing") private var isUpcomingTaskStackShowing: Bool = false

    var body: some View {
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
                        .foregroundStyle(isDatePickerPresented && nav.parent == pageType ? .black : highlighted ? .white : .white.opacity(0.8))
                }
            case .companies:
                HStack(alignment: .top, spacing: 0) {
                    if let colour = nav.session.job?.project?.company?.backgroundColor {
                        ActiveIndicator(colour: colour, href: .companies)
                    }
                    button.frame(width: 50, height: 50)
//                        .foregroundStyle(nav.session.job != nil ? nav.session.job!.backgroundColor : isDatePickerPresented && nav.parent == pageType ? .black : highlighted ? .white : .white.opacity(0.8))
                        .foregroundStyle(isDatePickerPresented && nav.parent == pageType ? .black : highlighted ? .white : .white.opacity(0.8))
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
                    img.font(.title).symbolRenderingMode(.hierarchical)
                } else {
                    Image(systemName: isDatePickerPresented && nav.parent == pageType ? "xmark" : (altMode != nil ? (altMode!.condition ? altMode!.icon : icon!) : icon!))
                        .font(.title)
                        .symbolRenderingMode(.hierarchical)
                }

            }
        }
        .help(label)
        .buttonStyle(.plain)
        .useDefaultHover({ hover in highlighted = hover})
    }

    private var FancyButton: some View {
        Button(action: {
            if isDatePickerPresented {
                isDatePickerPresented = false
            }

            if self.pageType == .planning {
                self.isUpcomingTaskStackShowing = false
            }

            self.nav.session.appPage = pageType.appPage
            nav.to(pageType)
        }, label: {
            ZStack {
                highlighted ? backgroundColour.opacity(0.9) : backgroundColour.opacity(1)
                Color.white
                    .opacity(0.4)
                    .blendMode(.softLight)

                if nav.parent != pageType {
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
                    .opacity(0.1)
                }

                if let img = self.iconAsImage {
                    img.font(.title).symbolRenderingMode(.hierarchical)
                } else {
                    Image(systemName: isDatePickerPresented && nav.parent == pageType ? "xmark" : (altMode != nil ? (altMode!.condition ? altMode!.icon : icon!) : icon!))
                        .font(.title)
                        .symbolRenderingMode(.hierarchical)
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
                if isDatePickerPresented {
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

        if self.highlighted {
            self.pageType.colour
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
