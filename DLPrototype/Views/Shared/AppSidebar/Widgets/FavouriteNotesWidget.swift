//
//  FavouriteNotesWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct FavouriteNotesWidget: View {
    public let title: String = "Favourite Notes"

    @State private var minimized: Bool = false
    
    @FetchRequest public var notes: FetchedResults<Note>
    
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
                VStack(alignment: .leading, spacing: 5) {
                    if notes.count > 0 {
                        ForEach(notes) { note in
                            NoteRowPlain(note: note, moc: moc, icon: "star")
                        }
                    } else {
                        Text("Star notes to see them here")
                    }
                    FancyDivider()
                }
            }
        }
    }
}

extension FavouriteNotesWidget {
    public init() {
        // TODO: Could make the limit based on a setting? Something to think about
        _notes = CoreDataNotes.starredFetchRequest(limit: 20)
    }
    
    private func actionMinimize() -> Void {
        withAnimation {
            minimized.toggle()
        }
    }
}
