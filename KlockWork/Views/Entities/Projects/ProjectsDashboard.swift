//
//  ProjectsDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

struct ProjectsDashboard: View {
    @EnvironmentObject public var state: Navigation
    @AppStorage("general.columns") private var numColumns: Int = 3
    @State private var projects: [Project] = []
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .projects
    private var columns: [GridItem] {
        Array(repeating: .init(.flexible(minimum: 100)), count: numColumns)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                UniversalHeader.Widget(
                    type: self.eType,
                    title: self.eType.label
                )
                if self.projects.count > 0 {
                    FancyHelpText(
                        text: "Projects own jobs, which define what needs to be done.",
                        page: self.page
                    )
                    FancyDivider()

                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: self.columns, alignment: .leading, spacing: 10) {
                            ForEach(self.projects, id: \.objectID) { project in
                                ProjectBlock(project: project)
                            }
                        }
                    }
                } else {
                    FancyHelpText(
                        text: "No companies found",
                        page: self.page
                    )
                }

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.state.session.project) { self.actionOnAppear() }
    }
}

extension ProjectsDashboard {
    /// Onload handler. Filters to current Project if one is selected
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let stored = self.state.session.project {
            self.projects = [stored]
        } else {
            self.projects = CoreDataProjects(moc: self.state.moc).alive()
        }
    }
}


struct ProjectBlock: View {
    typealias UI = WidgetLibrary.UI
    @EnvironmentObject public var state: Navigation
    public var project: Project
    @State private var highlighted: Bool = false
    @State private var jobCount: Int = 0

    var body: some View {
        Button {
            self.state.session.project = self.project
            self.state.to(.projectDetail)
        } label: {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    (project.alive ? project.backgroundColor : Color.gray)
                        .shadow(color: .black.opacity(1), radius: 3)
                        .opacity(highlighted ? 0.4 : 0.3)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            Image(systemName: self.highlighted ? "folder.fill" : "folder")
                                .foregroundStyle(self.project.company?.isDefault ?? false ? .yellow : self.highlighted ? project.backgroundColor.opacity(1) : project.backgroundColor.opacity(0.5))
                                .font(.system(size: 60))
                            VStack(alignment: .leading) {
                                Text(project.name ?? "_COMPANY_NAME")
                                    .multilineTextAlignment(.leading)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Spacer()
                                HStack(alignment: .center) {
                                    Spacer()
                                    UI.Chip(type: .jobs, count: self.jobCount)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding([.leading, .trailing, .top])
                }
            }
        }
        .clipShape(.rect(cornerRadius: 5))
        .onAppear(perform: self.actionOnAppear)
        .useDefaultHover({inside in highlighted = inside})
        .buttonStyle(.plain)
    }
}

extension ProjectBlock {
    private func actionOnAppear() -> Void {
        if let jobs = self.project.jobs?.allObjects as? [Job] {
            self.jobCount += jobs.count(where: {$0.alive})
        }
    }
}
