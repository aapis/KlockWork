//
//  ManageRecords.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ManageRecords: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.timestamp)]) public var records: FetchedResults<LogRecord>
    
    @State private var isDeleteConfirmationPresented: Bool = false
    
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {                
                HStack {
                    VStack(alignment: .leading) {
                        Title(text: "Records", image: "tray.fill")
                        
                        List(records, id: \.id) { record in
                            HStack {
                                Text("\(DateHelper.shortDateWithTime(record.timestamp!))")
                                
                                if record.job != nil {
                                    Text("\(record.job?.jid.string ?? "Invalid JID")")
                                } else {
                                    Text("Invalid JID")
                                }
                                
                                Text("\(record.message!)")
                                Spacer()
                                
                                // TODO: this prevents the view from building??
//                                    if record.postedDate != nil {
//                                        HStack {
//                                            Image(systemName: "pencil")
//                                            Text("HI")
//                                                .help("Updated \(DateHelper.shortDateWithTime(record.postedDate))")
//                                        }
//                                    }
                                
//                                FancyButton(text: "Delete", action: showDelete, icon: "xmark", transparent: true, showLabel: false)
//                                .confirmationDialog("Are you sure you want to delete?", isPresented: $isDeleteConfirmationPresented) {
//                                    Button("Yes", role: .destructive) {
////                                        delete(record)
//                                        print("NOTE: \(record.timestamp!)")
//                                        print("NOTE: \(record.message!)")
//                                    }
//                                    Button("Cancel", role: .cancel) {
//                                        hideDelete()
//                                    }
//                                }
                            }
                        }
                        .listStyle(.inset(alternatesRowBackgrounds: true))
                    }
                }
                .padding()
            }
            .background(Theme.toolbarColour)
        }
    }
    
//    @ViewBuilder
//    var buttons: some View {
//        if record.postedDate != nil {
//            Image(systemName: "pencil")
//                .help("Updated \(DateHelper.shortDateWithTime(record.postedDate))")
//        }
//
//        FancyButton(text: "Delete", action: showDelete, icon: "xmark", transparent: true, showLabel: false)
//        .confirmationDialog("Are you sure you want to delete?", isPresented: $isDeleteConfirmationPresented) {
//            Button("Yes", role: .destructive) {
//                delete(record)
//            }
//            Button("Cancel", role: .cancel) {
//                hideDelete()
//            }
//        }
//    }
//
    private func delete(_ record: LogRecord) -> Void {
        moc.delete(record)
        
        PersistenceController.shared.save()
    }
    
    private func showDelete() -> Void {
        isDeleteConfirmationPresented = true
    }
    
    private func hideDelete() -> Void {
        isDeleteConfirmationPresented = false
    }
}
