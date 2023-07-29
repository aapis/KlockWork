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
    public var showCreated: Bool? = false
    public var showUpdated: Bool? = false
    public var showCompleted: Bool? = false
    public var showCancelled: Bool? = false
    public var colourizeRow: Bool? = false
    public var showActions: Bool? = true
    
    @State private var completed: Bool = false
    @State private var cancelled: Bool = false
    @State private var editModeEnabled: Bool = false
    @State private var rowContent: String = ""
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    
    var body: some View {
        HStack(spacing: 0) {
            tProject()
            GridRow {
                Group {
                    ZStack {
                        colourize()
                        
                        if task.completedDate == nil {
                            FancyButton(text: "Complete", action: complete, icon: "circle", transparent: true, showLabel: false, fgColour: colourizeText())
                                .padding(5)
                        } else {
                            FancyButton(text: "Complete", action: complete, icon: "largecircle.fill.circle", transparent: true, showLabel: false, fgColour: colourizeText())
                                .padding(5)
                        }
                    }
                }
                .frame(width: 50)
                
                if showJobId == true {
                    Group {
                        ZStack(alignment: .leading) {
                            colourize()
                            
                            Text(task.owner?.jid.string ?? "No Job")
                                .padding(5)
                                .foregroundColor(colourizeText())
                        }
                    }
                    .frame(width: 100)
                }
                
                Group {
                    ZStack(alignment: .leading) {
                        colourize()
                        
                        if editModeEnabled {
                            FancyTextField(placeholder: task.content!, lineLimit: 1, onSubmit: edit, text: $rowContent)
                                .padding(5)
                        } else {
                            Text(task.content ?? "No content")
                                .padding(5)
                                .foregroundColor(colourizeText())
                        }
                    }
                }
                .frame(minWidth: 200)

                if showActions! {
                    Group {
                        ZStack(alignment: .trailing) {
                            colourize()

                            HStack {
                                if showCreated == true {
                                    Image(systemName: "clock.fill")
                                        .help(DateHelper.shortDateWithTime(task.created!))
                                        .help("Created \(DateHelper.shortDateWithTime(task.created!))")
                                        .padding(5)
                                        .foregroundColor(colourizeText())
                                }

                                if showUpdated == true && task.lastUpdate != nil {
                                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                        .help("Edited at \(DateHelper.shortDateWithTime(task.lastUpdate!))")
                                        .padding(5)
                                        .foregroundColor(colourizeText())
                                }

                                if showCompleted == true && task.completedDate != nil {
                                    Image(systemName: "checkmark.circle.fill")
                                        .help("Completed at \(DateHelper.shortDateWithTime(task.completedDate!))")
                                        .padding(5)
                                        .foregroundColor(colourizeText())
                                }

                                if showCancelled == true && task.cancelledDate != nil {
                                    Image(systemName: "xmark.app.fill")
                                        .help("Cancelled at \(DateHelper.shortDateWithTime(task.cancelledDate!))")
                                        .padding(5)
                                        .foregroundColor(colourizeText())

                                }


                                if task.cancelledDate == nil && task.completedDate == nil {
                                    FancyButton(text: "Cancel", action: cancel, icon: "xmark", showLabel: false, fgColour: colourizeText())
                                    FancyButton(text: "Edit", action: beginEdit, icon: "pencil", showLabel: false, fgColour: colourizeText())
                                }

                            }
                            .padding(.trailing, 5)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder private func tProject() -> some View {
        Group {
            HStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    if let owner = task.owner {
                        if let project = owner.project {
                            Color.fromStored(project.colour ?? Theme.rowColourAsDouble)
                        }
                    } else {
                        Theme.rowColour
                    }
                }
                Divider()
                    .foregroundColor(Theme.toolbarColour)
            }
        }
        .frame(width: 5)
    }
    
    private func colourize() -> Color {
        var colour = Theme.rowColour
        
        if task.completedDate != nil {
            colour = Theme.rowStatusGreen
        } else if task.cancelledDate != nil {
            colour = Theme.rowStatusRed
        }
        
        if colourizeRow == false {
            return colour
        } else {
            return Color.fromStored(task.owner!.colour!)
        }
    }
    
    private func colourizeText() -> Color {
        if task.completedDate == nil {
            if colourizeRow == false {
                return Color.white
            }
        
            return (Color.fromStored(task.owner!.colour!).isBright() ? Color.black : Color.white)
        }
        
        return Color.white
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
        CoreDataRecords(moc: moc).createWithJob(
            job: task.owner!,
            date: task.lastUpdate!,
            text: "Completed task: \(task.content ?? "Invalid task")"
        )
        
        withAnimation(.easeInOut(duration: 0.2)) {
            // update viewable status indicators
            completed = true
            updater.update()
        }
    }
    
    private func cancel() -> Void {
        CoreDataTasks(moc: moc).cancel(task)
        CoreDataRecords(moc: moc).createWithJob(
            job: task.owner!,
            date: task.lastUpdate!,
            text: "Cancelled task: \(task.content ?? "Invalid task")"
        )
        
        withAnimation(.easeInOut(duration: 0.2)) {
            // update viewable status indicators
            cancelled = true
            updater.update()
        }
    }
}
