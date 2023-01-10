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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack {
                HStack {
                    Title(text: "Tasks", image: "list.number")
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    Text("No tasks associated with this list yet")
                    
                    FancyTextField(placeholder: "What's on your mind?", lineLimit: 1, onSubmit: createTask, text: $entryText)
                    
                    if job.tasks!.count > 0 {
                        
                        ForEach(job.tasks!.allObjects as! [LogTask], id: \LogTask.id) { task in
                            Text("Task created: \(task.created!)")
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }
    
    private func createTask() -> Void {
        let task = LogTask(context: moc)
        task.created = Date()
        task.id = UUID()
        task.content = entryText
        task.owner = job
        
        PersistenceController.shared.save()
    }
}

