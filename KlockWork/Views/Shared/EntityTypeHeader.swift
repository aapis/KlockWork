//
//  EntityTypeHeader.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-07.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct EntityTypeHeader: View {
    @EnvironmentObject public var state: Navigation
    @State private var resourcePath: String = ""
    @State private var parts: [Item] = []
    @State private var defaultParts: [Item] = [
        Item(text: "...")
    ]
    public var title: String? = ""

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
                    }
                }
            }
        }
        .font(.title2)
        .onAppear(perform: self.actionSetViewState)
        .onChange(of: self.state.session.job) { self.actionSetViewState() }
        .onChange(of: self.state.session.project) { self.actionSetViewState() }
        .onChange(of: self.state.session.company) { self.actionSetViewState() }
    }

    struct Item: View, Identifiable {
        @EnvironmentObject public var state: Navigation
        public var id: UUID = UUID()
        public var text: String
        public var target: Page = .today
        @State private var isHighlighted: Bool = false

        var body: some View {
            HStack(alignment: .center) {
                Button {
                    self.state.to(self.target)
                } label: {
                    Text(self.text)
                        .underline(self.isHighlighted && self.target != .today) // using .today as "default"
                        .foregroundStyle((self.state.session.job?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base.opacity(0.55) : .white.opacity(0.55))
                        .multilineTextAlignment(.leading)
                }
                .buttonStyle(.plain)
                .disabled(self.target == .today)

                if [.companyDetail, .projectDetail, .today, .jobs].contains(where: {$0 == self.target}) {
                    Image(systemName: "chevron.right")
                        .foregroundStyle((self.state.session.job?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base.opacity(0.3) : .white.opacity(0.3))
                }
            }
            .useDefaultHover({ hover in self.isHighlighted = hover})
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
                            EntityTypeHeader(title: self.title)

                            HStack(alignment: .center) {
                                Spacer()
                                if let buttons = self.buttons {
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
                    EntityTypeHeader(title: self.title)
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

extension EntityTypeHeader {
    /// Fires onload and whenever the session job is changed. Compiles a breadcrumb based on selected job/project/company
    /// - Returns: Void
    private func actionSetViewState() -> Void {
        self.parts = []
        if let job = self.state.session.job {
            self.parts.append(Item(text: job.project?.company?.abbreviation ?? job.project?.company?.name ?? "", target: self.state.session.company?.pageDetailType ?? .dashboard))
            self.parts.append(Item(text: job.project?.abbreviation ?? job.project?.name ?? "", target: self.state.session.project?.pageDetailType ?? .dashboard))
            self.parts.append(Item(text: job.title ?? job.jid.string, target: job.pageDetailType))
        } else {
            if let company = self.state.session.company {
                self.parts = []
                if company.name != nil {
                    self.parts.append(Item(text: company.abbreviation ?? company.name ?? "", target: company.pageDetailType))
                }
            }
            if let project = self.state.session.project {
                self.parts = []
                if project.name != nil && project.company != nil {
                    self.parts.append(Item(text: project.company!.abbreviation ?? project.company!.name ?? "", target: project.company!.pageDetailType))
                    self.parts.append(Item(text: project.abbreviation ?? project.name ?? "", target: project.pageDetailType))
                }
            }
        }
    }
}
