//
//  TaskDashboardSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-03.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct TaskDashboardSidebar: View {
    @State public var date: Date = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(showsIndicators: false) {
                IncompleteTasksWidget()
            }

            Spacer()
        }
        .padding()
    }
}
