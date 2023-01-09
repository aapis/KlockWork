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
                
                Spacer()
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
