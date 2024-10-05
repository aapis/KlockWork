//
//  TaskItem.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-05.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct TaskItem: View {
    public let task: LogTask
    public var includeDueDate: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: 0) {
                Text(self.task.content ?? "")
                Spacer()
            }
            .padding(.bottom, 8)
            .foregroundStyle((self.task.owner?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base : .white)

            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    if let job = self.task.owner {
                        if let project = job.project {
                            if let company = project.company {
                                Text(company.abbreviation ?? "XXX")
                                Image(systemName: "chevron.right")
                            }

                            Text(project.abbreviation ?? "YYY")
                            Image(systemName: "chevron.right")
                        }

                        Text(job.title ?? job.jid.string)
                    }
                }

                if let due = self.task.due {
                    HStack(alignment: .center) {
                        Text("Due: \(due.formatted(date: self.includeDueDate ? .abbreviated : .omitted, time: .complete))")
                    }
                }
            }
            .foregroundStyle((self.task.owner?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base.opacity(0.55) : .white.opacity(0.55))
            .font(Theme.fontCaption)
        }
        .padding(8)
        .background(self.task.owner?.backgroundColor ?? Theme.rowColour)
    }
}
