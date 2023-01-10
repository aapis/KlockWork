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
    
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 22) {
                Title(text: "Create a note", image: "note.text.badge.plus")
                
                FancyTextField(placeholder: "Title", lineLimit: 1, onSubmit: {}, text: $title)
                
                FancyTextField(placeholder: "Content", lineLimit: 20, onSubmit: {}, transparent: true, text: $content)
                
                Spacer()
                
                HStack {
                    NavigationLink {
                        NoteDashboard()
                            .navigationTitle("Note dashboard")
                    } label: {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Dashboard")
                        }
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(Color.white)
                    
                    .font(.title3)
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .onHover { inside in
                        if inside {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    
                    Spacer()
                    FancyButton(text: "Create", action: save)
                }
            }.padding()
        }
        .background(Theme.toolbarColour)
    }
    
    private func save() -> Void {
        let note = Note(context: moc)
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
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .frame(width: 800, height: 800)
    }
}
