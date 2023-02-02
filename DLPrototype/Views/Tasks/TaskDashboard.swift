//
//  TaskDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct TaskDashboard: View {
    @State private var searchText: String = ""
    @State private var selectedJob: Int = 0
    @State private var job: Job?
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.jid, order: .reverse)]) public var jobs: FetchedResults<Job>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.id)]) public var tasks: FetchedResults<LogTask>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.pid)]) public var projects: FetchedResults<Project>
    
    private var pickerItems: [CustomPickerItem] {
        var items: [CustomPickerItem] = [CustomPickerItem(title: "Choose a job", tag: 0)]
        let projects = CoreDataProjects(moc: moc).all()
        
        for project in projects {
            if project.jobs!.count > 0 {
                items.append(CustomPickerItem(title: "Project: \(project.name!)", tag: Int(-1)))
                
                if project.jobs != nil {
                    let jobs = project.jobs!.allObjects as! [Job]
                    
                    for job in jobs {
                        items.append(CustomPickerItem(title: " - \(job.jid.string)", tag: Int(job.jid)))
                    }
                }
            }
        }
        
        return items
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Title(text: "Search tasks", image: "magnifyingglass")
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
            placeholder: "Search \(tasks.count) tasks across \(jobs.count) jobs in \(projects.count) projects"
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
                                Text("Job ID")
                                    .padding(5)
                            }
                        }
                        .frame(width: 100)
                        Group {
                            ZStack(alignment: .leading) {
                                Theme.headerColour
                                Text("Content")
                                    .padding(5)
                            }
                        }
                    }
                }
                .frame(height: 40)
                
                GridRow {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 1) {
                            ForEach(filter(tasks)) { task in
                                TaskView(task: task, showJobId: true, showDate: true)
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
            Divider()
                .frame(height: 20)
                .overlay(.clear)
                .foregroundColor(.clear)

            HStack {
                Title(text: "Manage tasks", image: "pencil")
            }
            
            JobPicker(onChange: change)
                .onAppear(perform: setJob)
                .onChange(of: selectedJob) { _ in
                    setJob()
                }
            
            if selectedJob > 0 {
                TaskListView(job: job!)
            }
        }
    }
    
    private func setJob() -> Void {
        if selectedJob > 0 {
            job = CoreDataJob(moc: moc).byId(Double(selectedJob))
        }
    }
    
    private func change(selected: Int, sender: String?) -> Void {
        selectedJob = selected
        
        setJob()
    }
    
    private func filter(_ tasks: FetchedResults<LogTask>) -> [LogTask] {
        return SearchHelper(bucket: tasks).exec($searchText)
    }
}
