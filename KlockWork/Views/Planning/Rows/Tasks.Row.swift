//
//  Task.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension Planning.Tasks {
    struct Row: View {
        var task: LogTask
        var colour: Color

        @State private var selected: Bool = true

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            HStack(alignment: .top) {
                Button {
                    if selected {
                        nav.planning.tasks.remove(task)
                    } else {
                        nav.planning.tasks.insert(task)
                    }

                    selected.toggle()
                } label: {
                    Image(systemName: selected ? "checkmark.square" : "square")
                        .foregroundColor(selected ? colour.isBright() ? .black : .white : .black.opacity(0.4))
                        .font(.title)

                    if let content = task.content {
                        Text("\(content)")
                            .foregroundColor(selected ? colour.isBright() ? .black : .white : .black.opacity(0.4))
                    }
                }
                .buttonStyle(.plain)
                .useDefaultHover({_ in})

                Spacer()
            }
            .padding(10)
            .background(colour)
            .onAppear(perform: actionOnAppear)
        }
    }
}

extension Planning.Tasks.Row {
    private func actionOnAppear() -> Void {
        if let plan = nav.session.plan {
            if let tasks = plan.tasks {
                if tasks.contains(task) {
                    selected = true
                } else {
                    selected = false
                }
            }
        }
    }
}
