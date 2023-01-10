//
//  ManageJobs.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ManageJobs: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.jid, order: .reverse)]) public var jobs: FetchedResults<Job>
    
    @Environment(\.managedObjectContext) var moc
    
    @State private var isDeleteConfirmationPresented: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Title(text: "Jobs", image: "square.grid.3x1.fill.below.line.grid.1x2")
                    
                    List(jobs, id: \.jid) { job in
                        let colour = Color.fromStored(job.colour ?? Theme.rowColourAsDouble)
                        HStack {
                            Text("\(format(job.jid))")
                                .foregroundColor(colour.isBright() ? Color.black : Color.white)
                            Spacer()
//                            FancyButton(text: "Delete", action: showDelete, icon: "xmark", transparent: true, showLabel: false)
//                            .confirmationDialog("Are you sure you want to delete?", isPresented: $isDeleteConfirmationPresented) {
//                                Button("Yes", role: .destructive) {
////                                        delete(record)
//                                    print("JOB: \(format(job.jid))")
//                                }
//                                Button("Cancel", role: .cancel) {
//                                    hideDelete()
//                                }
//                            }
                        }
                        .background(colour)
                    }
                    .listStyle(.inset(alternatesRowBackgrounds: true))
                }
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }
    
    private func delete(_ record: Job) -> Void {
        moc.delete(record)
        
        PersistenceController.shared.save()
    }
    
    private func showDelete() -> Void {
        isDeleteConfirmationPresented = true
    }
    
    private func hideDelete() -> Void {
        isDeleteConfirmationPresented = false
    }
    
    private func format(_ jid: Double) -> String{
        return String(format: "%1.f", jid)
    }
}
