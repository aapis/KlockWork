//
//  DetailsRow.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-03.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct DetailsRow: View {
    public var key: String
    public var value: String
    public var colour: Color
    public var linkAble: Bool? = false
    public var linkTarget: Note?
    
    var body: some View {
        HStack(spacing: 1) {
            ZStack(alignment: .leading) {
                colour
                
                if linkAble! {
                    NavigationLink {
                        NoteView(note: linkTarget!)
                            .navigationTitle("Editing note")
                    } label: {
                        HStack {
                            Image(systemName: "link")
                            Text(key)
                        }
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(Color.white)
                    .padding()
                    .onHover { inside in
                        if inside {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                } else {
                    Text(key)
                        .padding(10)
                        .foregroundColor(colour.isBright() ? Color.black : Color.white)
                }
            }.frame(width: 200)
            
            ZStack(alignment: .leading) {
                colour
                
                Text(value)
                    .padding(10)
                    .foregroundColor(colour.isBright() ? Color.black : Color.white)
                    .contextMenu {
                        Button(action: {ClipboardHelper.copy("\(colour)".debugDescription)}, label: {
                            Text("Copy colour code")
                        })
                    }
            }
        }
    }
}

struct DetailsRowPreview: PreviewProvider {
    static private var note: Note = Note()
    
    static var previews: some View {
        VStack {
            DetailsRow(key: "Linked row", value: "22", colour: Color.blue, linkAble: true, linkTarget: note)
            DetailsRow(key: "Standard row", value: "22", colour: Color.purple)
        }
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
