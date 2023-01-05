//
//  Note.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct NoteView: View {
    public var note: Note
    
    @State private var title: String = ""
    @State private var content: String = ""
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 22) {
                Title(text: "Editing", image: "pencil")
                
                LogTextField(placeholder: "Title", lineLimit: 1, onSubmit: {}, text: $title)
                
                LogTextField(placeholder: "Content", lineLimit: 20, onSubmit: {}, transparent: true, text: $content)
                
                Spacer()
                
                HStack {
                    Button(action: update) {
                        Text("Update")
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Text("Delete")
                    }
                }
            }.padding()
        }
        .background(Theme.toolbarColour)
        .onAppear(perform: {createBindings(note: note)})
        .onChange(of: note, perform: createBindings)
    }
    
    // TODO: copy/pasted from NoteCreate
    private func update() -> Void {
        note.title = title
        note.body = content

        PersistenceController.shared.save()
    }
    
    private func createBindings(note: Note) -> Void {
        title = note.title!
        content = note.body!
    }
}

struct NoteViewPreview: PreviewProvider {
    static var previews: some View {
        let note = Note()
        
        NoteView(note: note).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .frame(width: 800, height: 800)
    }
}
