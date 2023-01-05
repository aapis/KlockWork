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
            VStack(alignment: .leading, spacing: 22) {
                Title(text: "Create a note", image: "note.text.badge.plus")
                
                LogTextField(placeholder: "Title", lineLimit: 1, onSubmit: {}, text: $title)
                
                LogTextField(placeholder: "Content", lineLimit: 20, onSubmit: {}, transparent: true, text: $content)
                
                Spacer()
                
                Button(action: save) {
                    Text("Create")
                }
            }.padding()
        }
        .background(Theme.toolbarColour)
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
