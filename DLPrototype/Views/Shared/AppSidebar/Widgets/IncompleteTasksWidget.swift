//
//  RecentTasksWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct IncompleteTasksWidget: View {
    public let title: String = "Incomplete Tasks"

    @State private var minimized: Bool = false

    @FetchRequest public var resource: FetchedResults<LogTask>

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FancySubTitle(text: "\(title)")
                Spacer()
                FancyButtonv2(
                    text: "Minimize",
                    action: actionMinimize,
                    icon: minimized ? "plus" : "minus",
                    showLabel: false,
                    type: .white
                )
                .frame(width: 30, height: 30)
            }

            if !minimized {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(resource) { task in
//                        TaskView(task: task, showActions: false)
                        TaskViewPlain(task: task)
                    }
                }
            }
        }
    }
}

extension IncompleteTasksWidget {
    public init() {
        _resource = CoreDataTasks.recentTasksWidgetData()
    }

    private func actionMinimize() -> Void {
        withAnimation {
            minimized.toggle()
        }
    }
}

