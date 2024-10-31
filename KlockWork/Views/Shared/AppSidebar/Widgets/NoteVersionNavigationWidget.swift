//
//  NoteVersionNavigationWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-01.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct NoteVersionNavigationWidget: View {
    public var note: Note

    @Binding public var title: String
    @Binding public var content: String
    @Binding public var lastUpdate: Date?
    @Binding public var star: Bool?
    @Binding public var currentVersion: Int
    @Binding public var disableNextButton: Bool
    @Binding public var disablePreviousButton: Bool
    @Binding public var noteVersions: [NoteVersion]
    
    @State private var role: ItemRole = .standard

    @Environment(\.managedObjectContext) var moc

    private var versions: [NoteVersion] {
        CoreDataNoteVersions(moc: moc).by(id: note.id!)
    }

    @State private var highlighted: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ZStack(alignment: .center) {
                if role != .important {
                    role.colour.opacity(highlighted ? 0.15 : 0.08)
                } else {
                    role.colour
                }

                Button {
                    previousVersion()
                } label: {
                    Image(systemName: "arrowtriangle.left")
                        .font(.title2)
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                .useDefaultHover({ inside in highlighted = inside})
            }
            .frame(width: 50)

            ZStack(alignment: .topLeading) {
                role.colour.opacity(0.02)
                Text("v\(currentVersion)/\(noteVersions.count).\(DateHelper.shortDateWithTime(note.lastUpdate))")
//                Text("hi")
//                    .help(help)
//                    .padding()
            }
//            .onAppear(perform: onAppear)

            ZStack(alignment: .center) {
                if role != .important {
                    role.colour.opacity(highlighted ? 0.15 : 0.08)
                } else {
                    role.colour
                }
                Button {
                    nextVersion()
                } label: {
                    Image(systemName: "arrowtriangle.right")
                        .font(.title2)
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                .useDefaultHover({ inside in highlighted = inside})
            }
            .frame(width: 50)
        }
        .border(.black.opacity(0.2), width: 1)
        .mask(
            RoundedRectangle(cornerRadius: 4)
        )
        .frame(maxHeight: 50)

//        .contextMenu {
//            Button("Copy \(data)") {
//                ClipboardHelper.copy(data)
//            }
//        }
    }

    private func onAppear() -> Void {
        lastUpdate = note.lastUpdate
    }

    private func previousVersion() -> Void {
        let all = CoreDataNoteVersions(moc: moc).by(id: note.id!)

        if currentVersion > 0 {
            disableNextButton = false
            // change text fields
            let prev = all[currentVersion - 1]
            title = prev.title!
            content = prev.content!
            lastUpdate = prev.created!

            if currentVersion == noteVersions.count {
                let _ = CoreDataNoteVersions(moc: moc).from(note)
            }

            currentVersion -= 1
        } else {
            disablePreviousButton = true
        }
    }

    private func nextVersion() -> Void {
        let all = CoreDataNoteVersions(moc: moc).by(id: note.id!)

        if currentVersion < noteVersions.count {
            disablePreviousButton = false

            let next = all[currentVersion + 1]
            title = next.title!
            content = next.content!
            lastUpdate = next.created!

            currentVersion += 1
        } else {
            disableNextButton = true
        }
    }
}
