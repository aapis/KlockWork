//
//  Favourites.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct Favourites: View {
    public let title: String = "Favourite Notes"
    
    @FetchRequest public var notes: FetchedResults<Note>
    
    public init() {
        _notes = CoreDataNotes.starredFetchRequest(limit: 5)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            FancySubTitle(text: "\(title)")
            Divider()
            
            ScrollView {
                VStack(spacing: 1) {
                    ForEach(notes) { note in
                        NoteRow(note: note, showStarred: false, showRevisionCount: false, showActive: false)
                    }
                }
            }
        }
        .padding()
        .border(Theme.darkBtnColour)
    }
}
