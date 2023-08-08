//
//  NoteRowPlain.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct NoteRowPlain: View {
    public var note: Note
    public var moc: NSManagedObjectContext
    public var icon: String = "arrow.right"

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Image(systemName: icon)
                    .padding(.trailing, 10)
                    .opacity(0.4)

                FancyButtonv2(
                    text: note.title!,
                    action: {},
                    showIcon: false,
                    size: .link,
                    redirect: AnyView(NoteView(note: note, moc: moc)),
                    pageType: .notes,
                    sidebar: AnyView(NoteViewSidebar(note: note, moc: moc))
                )
                Spacer()
            }
            .padding(5)
        }
    }
}
