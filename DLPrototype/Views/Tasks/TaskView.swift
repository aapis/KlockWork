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
    public var task: LogTask
    
    @State private var completed: Bool = false
    
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        HStack(spacing: 1) {
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
                
                Group {
                    ZStack(alignment: .leading) {
                        (task.completedDate == nil ? Theme.rowColour : Theme.rowStatusGreen)
                        
                        Text(task.content ?? "No content")
                            .padding(5)
                    }
                }
                
            }
        }
    }
    
    private func complete() -> Void {
        CoreDataTasks(moc: moc).complete(task)
        // update viewable status indicators
        completed = true
    }
}
