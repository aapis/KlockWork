//
//  NoteSearchWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct NoteSearchWidget: View {
    public let title: String = "Find note"

    @State private var minimized: Bool = false
    @State private var query: String = ""

    @FetchRequest public var resource: FetchedResults<Note>

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FancySubTitle(text: "\(title)")
                Spacer()
                FancyButtonv2(
                    text: "Minimize",
                    action: actionMinimize,
                    icon: minimized ? "plus" : "minus",
                    showLabel: false,
                    type: .white
                )
                .frame(width: 30, height: 30)
            }

            if !minimized {
                VStack {
                    SearchBar(text: $query, disabled: minimized)
                        .onChange(of: query, perform: actionOnSearch)
                }

                VStack(alignment: .leading, spacing: 5) {
                    if resource.count > 0 {
                        ForEach(resource) { note in
                            NoteRowPlain(note: note, moc: moc, icon: "star")
                        }
                    } else {
                        SidebarItem(
                            data: "No notes matching query",
                            help: "No notes matching query",
                            role: .important
                        )
                    }
                    FancyDivider()
                }
            }
        }
    }
}

extension NoteSearchWidget {
    public init() {
        _resource = CoreDataNotes.fetchNotes()//(matching: $searchText)
    }

    private func actionOnSearch(term: String) -> Void {
//        resource.filter(({$0.title?.contains(term) ?? false}))
    }

    private func actionMinimize() -> Void {
        minimized.toggle()
    }

    private func actionSettings() -> Void {
//        isSettingsPresented.toggle()
    }
}
