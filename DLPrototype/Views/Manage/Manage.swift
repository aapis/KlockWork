//
//  Manage.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct Manage: View {
    @Environment(\.managedObjectContext) var moc

    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink("Notes", destination: ManageNotes().navigationTitle("Manage Notes"))
                NavigationLink("Records", destination: ManageRecords().navigationTitle("Manage Records"))
                NavigationLink("Jobs", destination: ManageJobs().navigationTitle("Manage Jobs"))
                NavigationLink("Tasks", destination: ManageTasks().navigationTitle("Manage Tasks"))
            }
        } detail: {
            ManageDashboard()
        }
        .navigationSplitViewStyle(.prominentDetail)
    }
}

struct ManagePreview: PreviewProvider {
    static var previews: some View {
        Manage().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
