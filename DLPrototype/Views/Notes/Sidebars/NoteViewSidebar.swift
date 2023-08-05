//
//  NoteViewSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct NoteViewSidebar: View {
    public var note: Note
    public var moc: NSManagedObjectContext?

    @State public var title: String = ""
    @State public var content: String = ""
    @State public var lastUpdate: Date?
    @State public var star: Bool? = false
    @State public var currentVersion: Int = 0
    @State public var disableNextButton: Bool = false
    @State public var disablePreviousButton: Bool = true
    @State public var noteVersions: [NoteVersion] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
//            Title(text: "Meta")
//            FancyDivider()
//
//            if let date = note.postedDate {
//                SidebarItem(
//                    data: date.formatted(),
//                    help: "Created on \(date.formatted())",
//                    icon: "calendar"
//                )
//            }
//
//            if let date = note.lastUpdate {
//                SidebarItem(
//                    data: date.formatted(),
//                    help: "Last editied at \(date)",
//                    icon: "pencil"
//                )
//            }
//
//            if let id = note.id {
//                SidebarItem(
//                    data: id.uuidString,
//                    help: "System ID: \(id.uuidString)",
//                    icon: "questionmark"
//                )
//            }
//
//            if note.alive {
//                SidebarItem(
//                    data: "Published",
//                    help: "Published on \(note.postedDate!.formatted())",
//                    icon: "eye"
//                )
//            } else {
//                SidebarItem(
//                    data: "Unpublished",
//                    help: "No longer published",
//                    icon: "eye.slash",
//                    role: .important
//                )
//            }
//
//            if let versions = note.versions {
//                SidebarItem(
//                    data: String(versions.count),
//                    help: "\(versions.count) versions saved",
//                    icon: "square.grid.3x1.fill.below.line.grid.1x2"
//                )
//
////                    NoteVersionNavigationWidget(
////                        note: note,
////                        title: title,
////                        content: content,
////                        lastUpdate: lastUpdate // TODO: this won't work since these are properties of NoteView, I need to pull all this version stuff out and refactor the whole view to move functionality to the sidebar
////                    )
//            } else {
//                SidebarItem(
//                    data: "0",
//                    help: "No versions saved yet",
//                    icon: "square.grid.3x1.fill.below.line.grid.1x2"
//                )
//            }
//
//            FancyDivider()
            Title(text: "Context")
//                FancyDivider()


//                Spacer()
        }
        .padding()
    }

    public init(note: Note, moc: NSManagedObjectContext) {
        self.note = note
        self.moc = moc
    }
}
