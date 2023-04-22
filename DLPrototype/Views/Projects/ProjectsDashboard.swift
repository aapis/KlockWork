//
//  ProjectsDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ProjectsDashboard: View {
    @State private var searchText: String = ""
    @State private var selected: Int = 0
    @State private var project: Project?
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var jobModel: CoreDataJob
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.jid, order: .reverse)]) public var jobs: FetchedResults<Job>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .reverse)]) public var projects: FetchedResults<Project>
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                create
                search

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }
    
    @ViewBuilder
    var create: some View {
        HStack {
            Title(text: "Create", image: "pencil")
        }
        
        FancyLink(icon: "folder.badge.plus", destination: AnyView(ProjectCreate().environmentObject(jobModel)))
        FancyDivider()
    }
    
    @ViewBuilder
    var search: some View {
        HStack {
            Title(text: "Search", image: "folder")
            Spacer()
        }
        
        SearchBar(
            text: $searchText,
            disabled: false,
            placeholder: "Search \(projects.count) projects"
        )
        
        if projects.count < 100 {
            Grid(horizontalSpacing: 1, verticalSpacing: 1) {
                HStack(spacing: 0) {
                    GridRow {
                        Group {
                            ZStack(alignment: .leading) {
                                Theme.headerColour
                                Text("Name")
                                    .padding()
                            }
                        }
                        
                        Group {
                            ZStack(alignment: .leading) {
                                Theme.headerColour
                                Text("# Jobs")
                                    .padding()
                            }
                        }
                        .frame(width: 100)
                    }
                }
                .frame(height: 46)
                
                projectsView
            }
            .font(Theme.font)
        }
    }
    
    @ViewBuilder
    var projectsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 1) {
                ForEach(filter(projects)) { project in
                    ProjectRow(project: project)
                        .environmentObject(jobModel)
                }
            }
        }
    }
    
    private func filter(_ projects: FetchedResults<Project>) -> [Project] {
        return SearchHelper(bucket: projects).findInProjects($searchText)
    }
}
