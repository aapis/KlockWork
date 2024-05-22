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
                    ForEach(items) { item in
                        NavigationLink {
                            NoteDetail(note: item)
                        } label: {
                            Text(item.title!)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .onAppear(perform: {
                items = CoreDataNotes(moc: moc).alive()
            })
            .navigationTitle("Notes")
            .toolbarBackground(Theme.cPurple, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
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
