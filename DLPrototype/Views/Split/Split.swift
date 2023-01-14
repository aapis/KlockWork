//
//  ExperimentalToday.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-05.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct Split: View {
    static public var modules: [CustomPickerItem] = [
        CustomPickerItem(title: "Today", tag: 1),
        CustomPickerItem(title: "Notes", tag: 2),
        CustomPickerItem(title: "Tasks", tag: 3),
        CustomPickerItem(title: "Projects", tag: 4),
        CustomPickerItem(title: "Import", tag: 5)
    ]
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.postedDate, order: .reverse)]) public var notes: FetchedResults<Note>
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject public var recordsModel: LogRecords
    
    @State public var left: Int = 0
    @State public var middle: Int = 0
    @State public var right: Int = 0
    
    @Binding public var direction: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Grid(verticalSpacing: 0) {
                GenericToolbar(left: $left, right: $right, middle: $middle)
            }
            Divider()
                .background(.black)
        
            if !direction {
                HSplitView {
                    viewColumns
                }
            } else {
                VSplitView {
                    viewColumns
                }
            }
        }
        .defaultAppStorage(.standard)
        .background(Color.black.opacity(0.2))
    }
    
    @ViewBuilder
    var viewColumns: some View {
        if left == 1 {
            Today().environmentObject(recordsModel)
        } else if left == 2 {
            NoteDashboard()
        } else if left == 3 {
            TaskDashboard()
        } else if left == 4 {
            ProjectsDashboard()
        } else if left == 5 {
            Import()
        } else {
            EmptyView()
        }
        
        // TODO: support 3 columns
//        if middle == 1 {
//            Today().environmentObject(recordsModel)
//        } else if middle == 2 {
//            NoteDashboard()
//        } else if middle == 3 {
//            TaskDashboard()
//        } else if middle == 4 {
//          ProjectsDashboard()
//        } else if middle == 5 {
//            Import()
//        } else {
//            EmptyView()
//        }
        
        if right == 1 {
            Today().environmentObject(recordsModel)
        } else if right == 2 {
            NoteDashboard()
        } else if right == 3 {
            TaskDashboard()
        } else if right == 4 {
            ProjectsDashboard()
        } else if right == 5 {
            Import()
        } else {
            EmptyView()
        }
    }
}

struct ExperimentalTodayPreview: PreviewProvider {
    @State static private var dir = false
    static var previews: some View {
        Split(direction: $dir)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(LogRecords(moc: PersistenceController.preview.container.viewContext))
    }
}
