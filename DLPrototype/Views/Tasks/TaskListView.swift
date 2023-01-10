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
                
                VStack(alignment: .leading, spacing: 1) {
                    FancyTextField(placeholder: "What's on your mind?", lineLimit: 1, onSubmit: createTask, text: $entryText)
                    
                    Divider()
                        .foregroundColor(.clear)
                        .frame(height: 10)
                        .overlay(.clear)
                    
                    if job.tasks!.count == 0 {
                        Text("No tasks associated with this list yet")
                    } else {
                        Grid(alignment: .top, horizontalSpacing: 1, verticalSpacing: 1) {
                            header.font(Theme.font)
                            
                            ScrollView {
                                ForEach(job.tasks!.allObjects as! [LogTask], id: \LogTask.id) { task in
                                    TaskView(task: task)
                                }
                            }
                        }
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
                ZStack(alignment: .leading) {
                    Theme.headerColour
                    Text("-")
                }
            }
            Group {
                ZStack(alignment: .leading) {
                    Theme.headerColour
                    Text("Created")
                }
            }
            Group {
                ZStack(alignment: .leading) {
                    Theme.headerColour
                    Text("Body")
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
        
        PersistenceController.shared.save()
    }
}

