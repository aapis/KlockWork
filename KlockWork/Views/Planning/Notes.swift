//
//  Notes.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension Planning {
    struct Notes: View {
        public var notes: FetchedResults<Note>
        public var colour: Color

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            if notes.count > 0 {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(notes, id: \.objectID) { note in
                        Row(note: note, colour: colour)
                    }
                }
            }
        }
    }
}
