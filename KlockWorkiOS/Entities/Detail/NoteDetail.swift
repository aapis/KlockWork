//
//  NoteDetail.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct NoteDetail: View {
    public let note: Note
    
    @State private var versions: [NoteVersion] = []
    @State private var current: NoteVersion? = nil
    @State private var content: String = ""
    @State private var title: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack {
                ScrollView(showsIndicators: false) {
                    Text(content)
                }
                .padding()
                Spacer()
            }
            .background(Theme.base)
        }
        .onAppear(perform: actionOnAppear)
        .navigationTitle(title.capitalized)
//        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.cPurple, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .background(Theme.cPurple)
        .toolbar {
            ToolbarItem {
                Button(action: {}) {
                    Label("Versions", systemImage: "questionmark.circle")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Text("Edit")
                }
            }
        }
    }
}

extension NoteDetail {
    private func actionOnAppear() -> Void {
        if let vers = note.versions {
            versions = vers.allObjects as! [NoteVersion]
            current = versions.first
            
            if let curr = current {
                title = curr.title ?? "_NOTE_TITLE"
                content = curr.content ?? "_NOTE_CONTENT"
            }
        } else if let body = note.body {
            title = note.title ?? "_NOTE_TITLE"
            content = body
        }
    }
}
