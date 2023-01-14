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
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.jid, order: .reverse)]) public var jobs: FetchedResults<Job>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .reverse)]) public var projects: FetchedResults<Project>
    
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
        
        FancyLink(icon: "folder.badge.plus", destination: AnyView(ProjectCreate()))
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
                                Text("Owned Jobs")
                                    .padding()
                            }
                        }
                        
                        Group {
                            ZStack(alignment: .leading) {
                                Theme.headerColour
                                Text("Alive")
                                    .padding()
                            }
                        }
                    }
                }
                .frame(height: 40)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        ForEach(filter(projects)) { project in
                            GridRow {
                                HStack(spacing: 1) {
                                    Group {
                                        ZStack(alignment: .leading) {
                                            Theme.rowColour
                                            FancyTextLink(text: project.name!, destination: AnyView(ProjectView(project: project)))
                                        }
                                    }
                                    
                                    Group {
                                        ZStack(alignment: .leading) {
                                            Theme.rowColour
                                            Text("\(project.jobs!.count)")
                                                .padding()
                                        }
                                    }
                                    
                                    Group {
                                        ZStack(alignment: .leading) {
                                            (project.alive ? Theme.rowStatusGreen : Color.red.opacity(0.2))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .font(Theme.font)
        }
    }
    
    private func filter(_ projects: FetchedResults<Project>) -> [Project] {
        return SearchHelper(bucket: projects).findInProjects($searchText)
    }
}
