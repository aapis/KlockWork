//
//  ExperimentalToday.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-05.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ExperimentalToday: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.postedDate, order: .reverse)]) public var notes: FetchedResults<Note>
    
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        HSplitView {
            Today()
            NotesHome()
        }
    }
}

struct ExperimentalTodayPreview: PreviewProvider {
    static var previews: some View {
        ExperimentalToday().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
