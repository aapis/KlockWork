//
//  Jobs.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Jobs: View {
    @State public var items: [Job] = []

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if items.count > 0 {
                        ForEach(items) { item in
                            NavigationLink {
                                JobDetail(job: item)
                            } label: {
                                Text(item.title != nil ? item.title!.isEmpty ? item.jid.string : item.title!.capitalized : item.jid.string)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    } else {
                        Button(action: addItem) {
                            Text("No jobs found. Create one!")
                        }
                    }
                }
            }
            .onAppear(perform: {
                items = CoreDataJob(moc: moc).all(true)
            })
            .toolbarBackground(Theme.cPurple, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }
}

extension Jobs {
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
//                modelContext.delete(items[index])
            }
        }
    }
}

