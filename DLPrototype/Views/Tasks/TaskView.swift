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
    
    var body: some View {
        HStack {
            GridRow {
                Group {
                    ZStack(alignment: .leading) {
                        Theme.rowColour
                        Text("-")
                    }
                }
                Group {
                    ZStack(alignment: .leading) {
                        Theme.rowColour
                        Text(task.created!.debugDescription)
                    }
                }
                Group {
                    ZStack(alignment: .leading) {
                        Theme.rowColour
                        Text(task.content ?? "No content")
                    }
                }
            }
        }
    }
}
