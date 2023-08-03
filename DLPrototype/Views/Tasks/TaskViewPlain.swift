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

    var body: some View {
        SidebarItem(
            data: task.content!,
            help: task.content!,
            icon: "circle"
        )
    }
}
