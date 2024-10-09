//
//  EntityTypeHeader.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-07.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct UniversalHeader: View {
    @EnvironmentObject public var state: Navigation
    @State private var resourcePath: String = ""
    @State private var parts: [Item] = []
    @State private var defaultParts: [Item] = [
        Item(text: "...")
    ]
    public var title: String? = ""
    public var entityType: PageConfiguration.EntityType
    private let maxBreadcrumbItemLength: Int = 30
    private let fontSize: Font = .title2

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 8) {
                if self.parts.count > 0 {
                    ForEach(self.parts, id: \.id) { part in part }
                } else {
                    if self.title == nil {
                        ForEach(self.defaultParts, id: \.id) { part in part }
                    } else {
                        Text(self.title!)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer()
            }
        }
        .font(self.fontSize)
        .onAppear(perform: self.actionSetViewState)
        .onChange(of: self.state.session.job) { self.actionSetViewState() }
        .onChange(of: self.state.session.project) { self.actionSetViewState() }
        .onChange(of: self.state.session.company) { self.actionSetViewState() }
    }

    struct Item: View, Identifiable {
        @EnvironmentObject public var state: Navigation
        public var id: UUID = UUID()
        public var text: String
        public var helpText: String = ""
        public var target: Page?
        @State private var isHighlighted: Bool = false

        var body: some View {
            HStack(alignment: .center) {
                if self.target == nil {
                    self.ItemText
                        .multilineTextAlignment(.leading)
                        .opacity(0.5)
                        .help(self.helpText)
                } else {
                    Button {
                        self.state.to(self.target!)
                    } label: {
                        self.ItemText
                            .multilineTextAlignment(.leading)
                    }
                    .useDefaultHover({ hover in self.isHighlighted = hover})
                    .help(self.helpText)
                    .buttonStyle(.plain)
                    .disabled(self.target! == .today)

                    Image(systemName: "chevron.right")
                        .foregroundStyle((self.state.session.job?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base.opacity(0.3) : .white.opacity(0.3))
                }
            }
        }

        @ViewBuilder var ItemText: some View {
            Text(self.text)
                .underline(self.isHighlighted && self.target != .today) // using .today as "default"
                .foregroundStyle(self.isHighlighted ? (self.state.session.job?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base : .white : (self.state.session.job?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base.opacity(0.55) : .white.opacity(0.55))
                .multilineTextAlignment(.leading)
        }
    }

    struct Widget: View {
        @EnvironmentObject public var state: Navigation
        public var type: PageConfiguration.EntityType
        public var buttons: AnyView?
        public var title: String?
        public var additionalDetails: AnyView?

        var body: some View {
            // @TODO: merge these two cases
            if self.additionalDetails != nil {
                ZStack(alignment: .topLeading) {
                    TypedListRowBackground(colour: self.state.session.job?.backgroundColor ?? Theme.rowColour, type: self.type)
                        .frame(height: 120)
                        .clipShape(.rect(topLeadingRadius: 5, topTrailingRadius: 5))

                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            UniversalHeader(title: self.title, entityType: self.type)

                            if let buttons = self.buttons {
                                HStack(alignment: .center) {
                                    Spacer()
                                    buttons
                                }
                            }
                        }
                        self.additionalDetails!
                    }
                    .padding()
                }
            } else {
                ZStack(alignment: .leading) {
                    TypedListRowBackground(colour: self.state.session.job?.backgroundColor ?? Theme.rowColour, type: self.type)
                        .frame(height: 60)
                        .clipShape(.rect(topLeadingRadius: 5, topTrailingRadius: 5))
                    UniversalHeader(title: self.title, entityType: self.type)
                        .padding(.leading)
                    HStack(alignment: .center) {
                        Spacer()
                        if let buttons = self.buttons {
                            buttons
                        }
                    }
                    .padding(.trailing)
                }
            }
        }
    }
}

extension UniversalHeader {
    /// Fires onload and whenever the session job is changed. Compiles a breadcrumb based on selected job/project/company
    /// - Returns: Void
    private func actionSetViewState() -> Void {
        self.parts = []
        if let job = self.state.session.job {
            self.parts.append(contentsOf:
                [
                    Item(
                        text: StringHelper.titleFrom(job.project?.company, max: self.maxBreadcrumbItemLength),
                        helpText: job.project?.company?.name ?? "",
                        target: self.state.session.company?.pageDetailType ?? .dashboard
                    ),
                    Item(
                        text: StringHelper.titleFrom(job.project, max: self.maxBreadcrumbItemLength),
                        helpText: job.project?.name ?? "",
                        target: self.state.session.project?.pageDetailType ?? .dashboard
                    ),
                    Item(
                        text: StringHelper.titleFrom(job, max: self.maxBreadcrumbItemLength),
                        helpText: job.title ?? job.jid.string,
                        target: job.pageDetailType
                    ),
                    Item(
                        // Sets last breadcrumb item text to page title (instead of entity type label) when Bruce says "It's time to DIE HARD"
                        text: self.entityType == .BruceWillis ? self.state.parent?.defaultTitle ?? "" : self.entityType.label
                    )
                ]
            )
        } else {
            if let company = self.state.session.company {
                self.parts = []
                if company.name != nil {
                    self.parts.append(
                        Item(
                            text: StringHelper.titleFrom(company, max: self.maxBreadcrumbItemLength),
                            helpText: company.name ?? "",
                            target: company.pageDetailType
                        )
                    )
                }
            }
            if let project = self.state.session.project {
                self.parts = []
                if project.name != nil && project.company != nil {
                    self.parts.append(contentsOf: [
                        Item(
                            text: StringHelper.titleFrom(project.company, max: self.maxBreadcrumbItemLength),
                            helpText: project.company?.name ?? "",
                            target: project.company!.pageDetailType
                        ),
                        Item(
                            text: StringHelper.titleFrom(project, max: self.maxBreadcrumbItemLength),
                            helpText: project.name ?? "",
                            target: project.pageDetailType
                        )
                    ])
                }
            }
        }
    }
}
