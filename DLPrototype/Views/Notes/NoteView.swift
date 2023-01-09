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
    @State private var isShowingEditor: Bool = true
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        VStack {
            if isShowingEditor {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 22) {
                        Title(text: "Editing", image: "pencil")
                        
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
                            
                            FancyButton(text: "Delete", action: delete)
                            Spacer()
                            FancyButton(text: "Update", action: update)
                        }
                    }.padding()
                }
                .background(Theme.toolbarColour)
            } else {
                NoteDashboard() // TODO: not a great idea, I think
            }
        }
        .onAppear(perform: {createBindings(note: note)})
        .onChange(of: note, perform: createBindings)
    }
    
    private func cancel() -> Void {
        isShowingEditor = false
    }
    
    private func update() -> Void {
        note.title = title
        note.body = content

        PersistenceController.shared.save()
    }
    
    private func delete() -> Void {
        managedObjectContext.delete(note)
        isShowingEditor = false
        title = ""
        content = ""
        
        PersistenceController.shared.save()
    }
    
    private func createBindings(note: Note) -> Void {
        title = note.title!
        content = note.body!
        isShowingEditor = true
    }
}

struct NoteViewPreview: PreviewProvider {
    static var previews: some View {
        let note = Note()
        
        NoteView(note: note).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .frame(width: 800, height: 800)
    }
}
