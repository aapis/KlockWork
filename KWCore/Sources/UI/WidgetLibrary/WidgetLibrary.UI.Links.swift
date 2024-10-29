//
//  WidgetLibrary.UI.Links.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-28.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension WidgetLibrary.UI {
    public struct Links {
        struct ToProject: View {
            @EnvironmentObject private var state: Navigation
            public var entity: Project?
            @State private var isHighlighted: Bool = false

            var body: some View {
                Button {
                    self.state.session.project = self.entity
                    self.state.to(.projectDetail)
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: self.isHighlighted ? "folder.fill" : "folder")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(self.entity?.backgroundColor ?? Theme.lightWhite)

                        Text(self.entity?.name ?? "Error: Invalid project name")
                        Spacer()
                    }
                    .help("Go to \(self.entity?.name ?? "Error: Invalid project name")")
                }
                .buttonStyle(.plain)
                .useDefaultHover({ hover in self.isHighlighted = hover})
                .padding(.leading)
            }
        }

        struct ToJob: View {
            @EnvironmentObject private var state: Navigation
            public var entity: Job?
            @State private var isHighlighted: Bool = false

            var body: some View {
                Button {
                    self.state.session.job = self.entity
                    self.state.to(.jobs)
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: self.isHighlighted ? "folder.fill" : "folder")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(self.entity?.backgroundColor ?? Theme.lightWhite)

                        Text(self.entity?.title ?? self.entity?.jid.string ?? "Error: Invalid job title and ID")
                        Spacer()
                    }
                    .help("Go to \(self.entity?.title ?? self.entity?.jid.string ?? "Error: Invalid job title and ID")")
                }
                .buttonStyle(.plain)
                .useDefaultHover({ hover in self.isHighlighted = hover})
                .padding(.leading)
            }
        }
    }
}
