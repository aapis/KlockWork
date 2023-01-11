//
//  ManageTasks.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-11.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ManageTasks: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .reverse)]) public var data: FetchedResults<LogTask>
    
    @Environment(\.managedObjectContext) var moc
    
    @State private var isDeleteConfirmationPresented: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Title(text: "Notes", image: "note.text")
                    
                    List(data, id: \.id) { task in
                        if task.owner != nil {
                            HStack {
                                Text("\(DateHelper.shortDateWithTime(task.created))")
                                    .foregroundColor(Color.fromStored(task.owner!.colour ?? Theme.rowColourAsDouble).isBright() ? Color.black : Color.white)
                                Text(task.content ?? "Invalid title")
                                    .foregroundColor(Color.fromStored(task.owner!.colour ?? Theme.rowColourAsDouble).isBright() ? Color.black : Color.white)
                                Spacer()
                                Text(task.owner!.jid.string)
                                    .foregroundColor(Color.fromStored(task.owner!.colour ?? Theme.rowColourAsDouble).isBright() ? Color.black : Color.white)
                                
                                
                                //                            FancyButton(text: "Delete", action: showDelete, icon: "xmark", transparent: true, showLabel: false)
                                //                            .confirmationDialog("Are you sure you want to delete?", isPresented: $isDeleteConfirmationPresented) {
                                //                                Button("Yes", role: .destructive) {
                                //                                    print("NOTE: \(note.title!)")
                                //                                    print("NOTE: \(note.postedDate!)")
                                ////                                        delete(note)
                                //                                }
                                //                                Button("Cancel", role: .cancel) {
                                //                                    hideDelete()
                                //                                }
                                //                            }
                            }
                            .background(task.completedDate == nil ? Color.fromStored(task.owner!.colour ?? Theme.rowColourAsDouble) : Theme.rowStatusGreen)
                        } else {
                            Text("Owner could not be determined for task \(task)")
                        }
                    }
                    .listStyle(.inset(alternatesRowBackgrounds: true))
                }
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }
    
    private func delete(_ note: Note) -> Void {
        moc.delete(note)
        
        PersistenceController.shared.save()
    }
    
    private func showDelete() -> Void {
        isDeleteConfirmationPresented = true
    }
    
    private func hideDelete() -> Void {
        isDeleteConfirmationPresented = false
    }
}
