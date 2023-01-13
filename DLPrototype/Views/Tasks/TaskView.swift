//
//  TaskEdit.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct TaskView: View {
    @ObservedObject public var task: LogTask
    public var showJobId: Bool? = false
    public var showDate: Bool? = false
    
    @State private var completed: Bool = false
    @State private var editModeEnabled: Bool = false
    @State private var rowContent: String = ""
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    
    var body: some View {
        HStack(spacing: 0) {
            GridRow {
                Group {
                    ZStack {
                        (task.completedDate == nil ? Theme.rowColour : Theme.rowStatusGreen)
                        
                        if task.completedDate == nil {
                            FancyButton(text: "Complete", action: complete, icon: "circle", transparent: true, showLabel: false)
                                .padding(5)
                        } else {
                            FancyButton(text: "Complete", action: complete, icon: "largecircle.fill.circle", transparent: true, showLabel: false)
                                .padding(5)
                        }
                    }
                }
                .frame(width: 50)
                
                if showJobId == true {
                    Group {
                        ZStack(alignment: .leading) {
                            (task.completedDate == nil ? Theme.rowColour : Theme.rowStatusGreen)
                            
                            Text(task.owner?.jid.string ?? "No Job")
                                .padding(5)
                        }
                    }
                    .frame(width: 100)
                }
                
                Group {
                    ZStack(alignment: .leading) {
                        (task.completedDate == nil ? Theme.rowColour : Theme.rowStatusGreen)
                        
                        if editModeEnabled {
                            FancyTextField(placeholder: task.content!, lineLimit: 1, onSubmit: edit, text: $rowContent)
                                .padding(5)
                        } else {
                            Text(task.content ?? "No content")
                                .padding(5)
                        }
                    }
                }
                
                if showDate == true {
                    Group {
                        ZStack(alignment: .leading) {
                            (task.completedDate == nil ? Theme.rowColour : Theme.rowStatusGreen)
                            
                            if task.completedDate != nil {
//                                Image(systemName: "pencil")
                                Text("C: \(DateHelper.shortDateWithTime(task.completedDate!))")
                                    .padding(5)
                            }
                        }
                        
                        
                    }
                    .frame(width: 150)
                    
                    Group {
                        ZStack(alignment: .leading) {
                            (task.completedDate == nil ? Theme.rowColour : Theme.rowStatusGreen)
                            
                            if task.lastUpdate != nil {
//                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("U: \(DateHelper.shortDateWithTime(task.lastUpdate!))")
                                    .padding(5)
                            }
                        }
                        
                        
                    }
                    .frame(width: 150)
                }
                
                Group {
                    ZStack(alignment: .leading) {
                        (task.completedDate == nil ? Theme.rowColour : Theme.rowStatusGreen)

                        FancyButton(text: "Edit", action: beginEdit, icon: "pencil", showLabel: false)
                    }
                    
                    
                }
                .frame(width: 30)
            }
        }
    }
    
    private func beginEdit() -> Void {
        editModeEnabled = true
    }
    
    private func edit() -> Void {
        if task.content != rowContent {
            task.content = rowContent
        }
        
        task.lastUpdate = Date()
        editModeEnabled = false
        
        PersistenceController.shared.save()
        
        withAnimation(.easeInOut(duration: 0.2)) {
            updater.update()
        }
    }
    
    private func complete() -> Void {
        CoreDataTasks(moc: moc).complete(task)
        
        task.lastUpdate = Date()
        CoreDataRecords(moc: moc).createWithJob(
            job: task.owner!,
            date: task.lastUpdate!,
            text: "Completed task: \(task.content ?? "Invalid task")"
        )
        
        PersistenceController.shared.save()
        
        withAnimation(.easeInOut(duration: 0.2)) {
            // update viewable status indicators
            completed = true
            updater.update()
        }
    }
}
