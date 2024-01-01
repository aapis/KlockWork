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

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                if let job = note.mJob {
                    Image(systemName: icon)
                        .padding(.trailing, 10)
                        .opacity(0.4)
                        .foregroundColor(job.colour_from_stored().isBright() ? .black : .white)

                    FancyButtonv2(
                        text: note.title!,
                        action: actionOpenNote,
                        fgColour: job.colour_from_stored().isBright() ? .black : .white,
                        showIcon: false,
                        size: .link,
                        redirect: AnyView(NoteCreate(note: note)),
                        pageType: .notes,
                        sidebar: AnyView(NoteCreateSidebar(note: note))
                    )
                }
                Spacer()
            }
            .padding(5)
            .background(note.mJob != nil ? note.mJob!.colour_from_stored() : .clear)
        }
    }
}

extension NoteRowPlain {
    private func actionOpenNote() -> Void {
        nav.setId()
        nav.setParent(.notes)
        nav.session.note = note
        nav.setView(AnyView(NoteCreate(note: note)))
        nav.setSidebar(AnyView(NoteCreateSidebar(note: note)))
    }
}

