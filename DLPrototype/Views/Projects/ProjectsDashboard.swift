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
    
    private var pickerItems: [CustomPickerItem] {
        var items: [CustomPickerItem] = [CustomPickerItem(title: "Your projects", tag: 0)]
        
        for project in projects {
            items.append(CustomPickerItem(title: project.name!, tag: Int(project.pid)))
        }
        
        return items
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Title(text: "Search", image: "folder")
                    Spacer()
                }

                search
                create

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }
    
    @ViewBuilder
    var search: some View {
        SearchBar(
            text: $searchText,
            disabled: false,
            placeholder: "Search \(projects.count) projects"
        )
        
        if searchText != "" {
            Grid(horizontalSpacing: 1, verticalSpacing: 1) {
                HStack(spacing: 0) {
                    GridRow {
                        Group {
                            ZStack(alignment: .leading) {
                                Theme.headerColour
                            }
                        }
                        .frame(width: 50)
                        Group {
                            ZStack(alignment: .leading) {
                                Theme.headerColour
                                Text("Name")
                                    .padding(5)
                            }
                        }
                        .frame(width: 100)
                        Group {
                            ZStack(alignment: .leading) {
                                Theme.headerColour
                                Text("Owned Jobs")
                                    .padding(5)
                            }
                        }
                    }
                }
                .frame(height: 40)
                
                GridRow {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 1) {
                            ForEach(filter(projects)) { task in
                                ProjectCreate()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var create: some View {
        if searchText == "" {
            FancyDivider()

            HStack {
                Title(text: "Manage", image: "pencil")
            }
            
            FancyLink(destination: AnyView(ProjectCreate()))
            FancyDivider()
            FancyPicker(onChange: change, items: pickerItems)
                .onAppear(perform: setProject)
                .onChange(of: selected) { _ in
                    setProject()
                }
            
            if selected > 0 {
//                TaskListView(job: job!)
            }
        }
    }
    
    private func setProject() -> Void {
        if selected > 0 {
            project = CoreDataProjects(moc: moc).byId(selected)
        }
    }
    
    private func change(select: Int, sender: String?) -> Void {
        selected = select
        
        setProject()
    }
    
    private func filter(_ projects: FetchedResults<Project>) -> [Project] {
        return SearchHelper(bucket: projects).findInProjects($searchText)
    }
}
