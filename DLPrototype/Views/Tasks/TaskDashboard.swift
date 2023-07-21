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
    public var defaultSelectedJob: Job?
    
    @State private var searchText: String = ""
    @State private var selectedJob: Int = 0
    @State private var jobId: String = ""
    @State private var job: Job?
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var jm: CoreDataJob
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.jid, order: .reverse)]) public var jobs: FetchedResults<Job>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.id)]) public var tasks: FetchedResults<LogTask>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.pid)]) public var projects: FetchedResults<Project>
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Title(text: "Search tasks", image: "magnifyingglass")
                    Spacer()
                }

                search.font(Theme.font)
                create

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .onAppear(perform: setJob)
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
                HStack(spacing: 1) {
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
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 1) {
                            ForEach(filter(tasks)) { task in
                                TaskView(task: task, showJobId: true, showCreated: true, showUpdated: true, showCompleted: true, colourizeRow: true)
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
            
            JobPickerUsing(onChange: change, jobId: $jobId)
                .onAppear(perform: setJob)
                .onChange(of: selectedJob) { _ in
                    setJob()
                }
            
            if job != nil {
                TaskListView(job: job!)
            }
        }
    }
    
    private func setJob() -> Void {
        if defaultSelectedJob != nil {
//            if selectedJob == 0 {
                job = defaultSelectedJob
//            }
        } else if selectedJob > 0 {
            job = jm.byId(Double(selectedJob))
        }
        
        if job != nil {
            jobId = job!.jid.string
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
