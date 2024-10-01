//
//  Tasks.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

extension Planning {
    struct Tasks: View {
        public var tasks: FetchedResults<LogTask>
        public var colour: Color

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(tasks, id: \.objectID) { task in
                    Row(task: task, colour: colour)
                }
                .onAppear(perform: actionOnAppear)
            }
        }
    }
}

extension Planning.Tasks {
    private func actionOnAppear() -> Void {
        nav.planning.tasks = nav.planning.tasks.filter {$0.completedDate == nil && $0.cancelledDate == nil}
    }
}
