//
//  Tasks.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Tasks: View {
    @State public var items: [LogTask] = []

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if items.count > 0 {
                        ForEach(items) { item in
                            NavigationLink {
                                TaskDetail(task: item)
                            } label: {
                                Text(item.content!)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    } else {
                        Button(action: addItem) {
                            Text("No tasks found. Create one!")
                        }
                    }
                }
            }
            .onAppear(perform: {
                items = CoreDataTasks(moc: moc).all()
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

extension Tasks {
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
