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
    @State private var lastUpdate: Date?
    @State private var star: Bool? = false
    @State private var isShowingEditor: Bool = true
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        VStack {
            if isShowingEditor {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 22) {
                        HStack {
                            Title(text: "Editing", image: "pencil")
                            
                            Spacer()
                            
                            if note.starred {
                                FancyButton(text: "Un-favourite", action: starred, icon: "star.fill", showLabel: false)
                                    .keyboardShortcut("+")
                            } else {
                                FancyButton(text: "Favourite", action: starred, icon: "star", showLabel: false)
                            }
                        }
                        
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
                            
                            if lastUpdate != nil {
                                Text("Last update: \(DateHelper.shortDateWithTime(lastUpdate))")
                                
                                Image(systemName: "pencil")
                                    .help("Created: \(DateHelper.shortDateWithTime(lastUpdate))")
                            }
                            
                            FancyButton(text: "Update", action: update)
                                .keyboardShortcut("s")
                        }
                    }
                    .padding()
                }
                .background(Theme.toolbarColour)
            } else {
                NoteDashboard() // TODO: not a great idea, I think
            }
        }
        .onAppear(perform: {createBindings(note: note)})
        .onChange(of: note, perform: createBindings)
    }
    
    private func starred() -> Void {
        note.starred.toggle()
        
        update()
    }
    
    private func cancel() -> Void {
        isShowingEditor = false
    }
    
    private func update() -> Void {
        note.title = title
        note.body = content
        note.lastUpdate = Date()
        lastUpdate = note.lastUpdate

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
        lastUpdate = note.lastUpdate ?? nil
        isShowingEditor = true
    }
}

//struct NoteViewPreview: PreviewProvider {
//    static var previews: some View {
//        let note = Note()
//
//        NoteView(note: note).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//            .frame(width: 800, height: 800)
//    }
//}
