//
//  NoteDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-08.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct NoteDashboard: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest public var recent: FetchedResults<Note>
    @FetchRequest public var starred: FetchedResults<Note>
    
    public init() {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.fetchLimit = 5
        request.predicate = NSPredicate(format: "postedDate > %@ && alive = true", DateHelper.daysPast(7))
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Note.lastUpdate, ascending: false),
            NSSortDescriptor(keyPath: \Note.postedDate, ascending: false)
        ]
        
        _recent = FetchRequest(fetchRequest: request, animation: .easeInOut)
        
        let starReq: NSFetchRequest<Note> = Note.fetchRequest()
        starReq.fetchLimit = 5
        starReq.predicate = NSPredicate(format: "starred = true && alive = true")
        starReq.sortDescriptors = [
            NSSortDescriptor(keyPath: \Note.lastUpdate, ascending: false)
        ]
        
        _starred = FetchRequest(fetchRequest: starReq, animation: .easeInOut)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                HStack {
                    Title(text: "Long-form", image: "note.text")
                    Spacer()
                }
            }.padding()
            
            VStack(alignment: .leading) {
                Text("Please select a note, or create a new one")
                
                NavigationLink {
                    NoteCreate()
                        .navigationTitle("Create a note")
                } label: {
                    Image(systemName: "note.text.badge.plus")
                    
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
                
                VStack(alignment: .leading) {
                    Divider()
                        .frame(height: 20)
                        .foregroundColor(.clear)

                    HStack {
                        if starred.count > 0 {
                            VStack(alignment: .leading) {
                                Text("Favourites")
                                    .font(.title2)
                                
                                List(starred) { note in
                                    NavigationLink {
                                        NoteView(note: note)
                                            .navigationTitle("Editing note \(note.title!)")
                                    } label: {
                                        HStack {
                                            Text(note.title!)
                                            Spacer()
                                            Text("v\(note.versions?.count ?? 0)")
                                                .help("Current version")
                                            if note.lastUpdate != nil {
                                                Image(systemName: "arrow.triangle.2.circlepath")
                                                    .help("Updated \(DateHelper.shortDateWithTime(note.lastUpdate!))")
                                            } else {
                                                Image(systemName: "note.text.badge.plus")
                                                    .help("Created \(DateHelper.shortDateWithTime(note.postedDate!))")
                                            }
                                            
//                                            FancyButton(text: "Star", action: {}, icon: "star.fill", altIcon: "star", transparent: true, showLabel: false)
                                        }
                                    }
                                }
                                .listStyle(.inset(alternatesRowBackgrounds: true))
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Recent Notes")
                                .font(.title2)
                            
                            List(recent) { note in
                                NavigationLink {
                                    NoteView(note: note)
                                        .navigationTitle("Editing note \(note.title!)")
                                } label: {
                                    HStack {
                                        Text(note.title!)
                                        Spacer()
                                        Text("v\(note.versions?.count ?? 0)")
                                            .help("Current version")
                                        if note.lastUpdate != nil {
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                                .help("Updated \(DateHelper.shortDateWithTime(note.lastUpdate!))")
                                        } else {
                                            Image(systemName: "pencil")
                                                .help("Created \(DateHelper.shortDateWithTime(note.postedDate!))")
                                        }
                                        
//                                        FancyButton(text: "Delete", action: {}, icon: "xmark", transparent: true, showLabel: false)
//                                        FancyButton(text: "Star", action: {}, icon: "star", altIcon: "star.fill", transparent: true, showLabel: false)
                                    }
                                }
                            }
                            .listStyle(.inset(alternatesRowBackgrounds: true))
                        }
                    }
                }
            }.padding()
        }
        .background(Theme.toolbarColour)
    }
}

struct NoteDashboardPreview: PreviewProvider {
    static var previews: some View {
        NoteDashboard()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
