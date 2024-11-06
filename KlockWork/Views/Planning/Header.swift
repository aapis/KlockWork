//
//  Header.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension Planning {
    struct Header: View {
        var job: Job
        var index: Int?
        var type: PlanningObjectType

        @State private var colour: Color = .clear
        @State private var highlighted: Bool = false
        @State private var numChildren: Int = 0

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    if type == .tasks {
                        Text("\(self.numChildren) Incomplete tasks")
                    } else if type == .notes {
                        Text("\(self.numChildren) Notes")
                    }
                    Spacer()
                    if type == .tasks {
                        UI.Buttons.CreateTask()
                    } else if type == .notes {
                        UI.Buttons.CreateNote()
                    }
                }
                .padding([.leading, .trailing], 8)
            }
            .foregroundStyle(.white)
            .onAppear(perform: actionOnAppear)
            .background(Theme.rowColour)
        }
    }
}

extension Planning.Header {
    private func actionOnAppear() -> Void {
        colour = Color.fromStored(job.colour!)

        if type == .tasks {
            if let tasks = job.tasks {
                numChildren = tasks.filtered(using: NSPredicate(format: "completedDate == nil && cancelledDate == nil")).count
            }
        } else if type == .notes {
            if let notes = job.mNotes {
                numChildren = notes.filtered(using: NSPredicate(format: "alive == true")).count
            }
        }
    }
}
