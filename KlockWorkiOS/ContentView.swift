//
//  ContentView.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-18.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import SwiftData

struct NoteView: View {
    public let note: Note
    
    @State private var versions: [NoteVersion] = []
    @State private var current: NoteVersion? = nil
    @State private var content: String = ""
    @State private var title: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                HStack {
                    Text(title)
                        .font(.title)
                    Spacer()
                }
            }
            .padding()

            HStack {
                ScrollView(showsIndicators: false) {
                    Text(content)
                }
                .padding()
                Spacer()
            }
            .background(Theme.base)
        }
        .onAppear(perform: actionOnAppear)
        .background(Theme.cPurple)
//        .toolbar {
//            ToolbarItem {
//                Button(action: {}) {
//                    Label("Versions", systemImage: "questionmark.circle")
//                }
//            }
//        }
    }
}

extension NoteView {
    private func actionOnAppear() -> Void {
        if let vers = note.versions {
            versions = vers.allObjects as! [NoteVersion]
            current = versions.first
            
            if let curr = current {
                title = curr.title ?? "_NOTE_TITLE"
                content = curr.content ?? "_NOTE_CONTENT"
            }
        } else if let body = note.body {
            title = note.title ?? "_NOTE_TITLE"
            content = body
        }
    }
}

struct ContentView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]
    @Binding public var items: [Note]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        NoteView(note: item)
                    } label: {
                        Text(item.title!)
                    }
                }
                .onDelete(perform: deleteItems)
            }
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
        } detail: {
            Text("Select an item")
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

//#Preview {
//    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
//}
