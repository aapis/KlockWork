//
//  NoteCreate.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct NoteCreate: View {
    @State private var title: String = ""
    @State private var content: String = ""
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                ZStack {
                    Theme.toolbarColour
                    
                    VStack {
                        
                        Text("Create a note")
                        TextField("Title", text: $title)
                        TextField("Content", text: $content)
                        
                        Button(action: save) {
                            Text("Save")
                        }
                    }
                }
            }
        }
    }
    
    private func save() -> Void {
        let note = Note(context: managedObjectContext)
        note.title = title
        note.body = content
        note.postedDate = Date()
        note.id = UUID()

        PersistenceController.shared.save()
    }
}

struct NoteCreatePreview: PreviewProvider {
    static var previews: some View {
        NoteCreate()
            .frame(width: 800, height: 800)
    }
}
