//
//  TaskViewPlain.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-03.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct TaskViewPlain: View {
    public var task: LogTask

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater

    var body: some View {
        SidebarItem(
            data: task.content!,
            help: task.content!,
            icon: "circle",
            type: .thin,
            action: completeAction
        )
    }
}

extension TaskViewPlain {
    private func completeAction() -> Void {
        CoreDataTasks(moc: moc).complete(task)
        updater.updateOne("sidebar.today.incompleteTasksWidget")
    }
}
