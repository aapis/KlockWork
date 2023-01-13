//
//  TaskListView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct TaskListView: View {
    public var job: Job
    
    @State private var entryText: String = ""
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    
    private var tasks: [LogTask] {
        let list = job.tasks!.allObjects as! [LogTask]
        
        func deprioritizeCompleted(_ first: LogTask,_  second: LogTask) throws -> Bool {
            if first.completedDate != nil && second.completedDate != nil {
                return first.completedDate! < second.completedDate!
            }
            
            return first.completedDate == nil
        }
        
        do {
            return try list.sorted(by: deprioritizeCompleted)
        } catch {
            return list
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack {
                HStack {
                    Title(text: "Tasks", image: "list.number")
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    FancyTextField(placeholder: "Add a task to \(job.jid.string)", lineLimit: 1, onSubmit: createTask, text: $entryText)
                    
                    Divider()
                        .foregroundColor(.clear)
                        .frame(height: 20)
                        .overlay(.clear)
                    
                    if job.tasks!.count == 0 {
                        Text("No tasks associated with this list yet")
                    } else {
                        Grid(alignment: .top, horizontalSpacing: 1, verticalSpacing: 1) {
                            header.font(Theme.font)
                            
                            ScrollView {
                                VStack(spacing: 1) {
                                    ForEach(tasks, id: \LogTask.id) { task in
                                        TaskView(task: task)
                                    }
                                }
                            }
                        }
                        .id(updater.ids["tlv.table"])
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }
    
    @ViewBuilder
    var header: some View {
        GridRow {
            Group {
                ZStack {
                    Theme.headerColour
                }
            }
            .frame(width: 50)

            Group {
                ZStack(alignment: .leading) {
                    Theme.headerColour
                    Text("Tasks for \(job.jid.string)")
                        .padding(5)
                }
            }
        }
        .frame(height: 40)
    }
    
    private func createTask() -> Void {
        let task = LogTask(context: moc)
        task.created = Date()
        task.id = UUID()
        task.content = entryText
        task.owner = job

        entryText = ""
        updater.update()
        
        PersistenceController.shared.save()
    }
}

