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

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if self.parts.count > 0 {
                ForEach(self.parts, id: \.id) { part in part }
            } else {
                Item(
                    text: "Choose a job from the sidebar, type into the field below. Enter/Return/+ to create records."
                )
            }
        }
        .padding([.leading, .trailing])
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
        public var target: Page = .dashboard
        @State private var isHighlighted: Bool = false

        var body: some View {
            HStack(alignment: .center) {
                Button {
                    self.state.to(self.target)
                } label: {
                    Text(self.text)
                        .underline(self.isHighlighted && self.target != .dashboard) // using .dashboard as "default"
                        .foregroundStyle((self.state.session.job?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base.opacity(0.55) : .white.opacity(0.55))
                }
                .buttonStyle(.plain)

                if self.text != self.state.session.job?.title && self.target != .dashboard {
                    Image(systemName: "chevron.right")
                        .foregroundStyle((self.state.session.job?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base.opacity(0.3) : .white.opacity(0.3))
                }
            }
            .useDefaultHover({ hover in self.isHighlighted = hover})
        }
    }
}

extension EntityTypeHeader {
    /// Fires onload and whenever the session job is changed. Compiles a breadcrumb based on selected job/project/company
    /// - Returns: Void
    private func actionSetViewState() -> Void {
        self.parts = []
        if let job = self.state.session.job {
            self.parts.append(Item(text: job.project?.company?.name ?? "", target: self.state.session.company?.pageDetailType ?? .dashboard))
            self.parts.append(Item(text: job.project?.name ?? "", target: self.state.session.project?.pageDetailType ?? .dashboard))
            self.parts.append(Item(text: job.title ?? job.jid.string, target: job.pageDetailType))
        } else {
            if let company = self.state.session.company {
                self.parts = []
                if company.name != nil {
                    self.parts.append(Item(text: company.name!, target: company.pageDetailType))
                }
            }
            if let project = self.state.session.project {
                self.parts = []
                if project.name != nil && project.company != nil {
                    self.parts.append(Item(text: project.company!.name!, target: project.company!.pageDetailType))
                    self.parts.append(Item(text: project.name!, target: project.pageDetailType))
                }
            }
        }
    }
}
