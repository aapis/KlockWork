//
//  Notes.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Notes: View {
    @State public var items: [Note] = []

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if items.count > 0 {
                        ForEach(items) { item in
                            NavigationLink {
                                NoteDetail(note: item)
                            } label: {
                                Text(item.title!.capitalized)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    } else {
                        Button(action: addItem) {
                            Text("No notes found. Create one!")
                        }
                    }
                }
            }
            .onAppear(perform: {
                items = CoreDataNotes(moc: moc).alive()
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

extension Notes {
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
