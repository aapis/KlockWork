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
    public var category: Category
    public var records: Records
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.postedDate, order: .reverse)]) public var notes: FetchedResults<Note>
    
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        HSplitView {
            Add(category: category, records: records)
            NotesHome()
        }
    }
}

struct ExperimentalTodayPreview: PreviewProvider {
    static var previews: some View {
        ExperimentalToday(category: Category(title: "Daily"), records: Records()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
