//
//  NotesWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct NotesWidget: View {
    public var title: String = "Notes"
    public var favouritesOnly: Bool = false

    @State private var minimized: Bool = false
    @State private var query: String = ""
    @State private var isLoading: Bool = false
    @State private var isSettingsPresented: Bool = false
    @State private var grouped: Dictionary<Job, [Note]> = [:]
    @State private var sorted: [EnumeratedSequence<Dictionary<Job, [Note]>.Keys>.Element] = []

    @FetchRequest public var resource: FetchedResults<Note>

    @AppStorage("widget.notesearch.minimizeAll") private var minimizeAll: Bool = false

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        if isLoading {
            UI.WidgetLoading()
        } else {
            NotesWidget
        }
    }

    var NotesWidget: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                Spacer()
                HStack {
                    FancyButtonv2(
                        text: "Settings",
                        action: actionSettings,
                        icon: "gear",
                        showLabel: false,
                        type: .clear,
                        twoStage: true
                    )
                    .frame(width: 30, height: 30)
                }
                
            }
            .padding(10)
            .background(Theme.base.opacity(0.2))

            VStack {
                if isSettingsPresented {
                    Settings(
                        minimizeAll: $minimizeAll
                    )
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        if sorted.count > 0 {
                            ForEach(sorted, id: \.element) { index, key in
                                NoteGroup(index: index, key: key, notes: grouped)
                            }
                        } else {
                            if nav.session.gif == .normal {
                                SidebarItem(
                                    data: "No results for query \(query)",
                                    help: "No results for query \(query)",
                                    role: .important
                                )
                            } else if nav.session.gif == .focus {
                                Button {
                                    nav.setView(AnyView(Planning()))
                                    nav.setId()
                                    nav.setTitle("Update your plan")
                                    nav.setParent(.planning)
                                    nav.setSidebar(AnyView(DefaultPlanningSidebar()))
                                } label: {
                                    SidebarItem(
                                        data: "Add notes to your plan...",
                                        help: "Add notes to your plan",
                                        role: .action
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(8)
            .background(Theme.base.opacity(0.2))
        }
        .onAppear(perform: actionOnAppear)
    }
}

extension NotesWidget {
    public init(favouritesOnly: Bool = false) {
        self.favouritesOnly = favouritesOnly
        _resource = CoreDataNotes.fetchNotes(favouritesOnly: self.favouritesOnly)
        
        if favouritesOnly {
            self.title = "Favourites"
        }
    }

    private func actionOnAppear() -> Void {
        if nav.session.gif == .focus {
            if let plan = nav.session.plan {
                if let setJobs = plan.jobs {
                    let jobs = setJobs.allObjects as! [Job]
                    query = jobs.map({$0.jid.string}).joined(separator: ", ")
                }

                if let setNotes = plan.notes {
                    let notes = setNotes.allObjects as! [Note]
                    grouped = Dictionary(grouping: notes, by: {$0.mJob!})
                }
            }
        } else {
            grouped = Dictionary(grouping: resource, by: {$0.mJob!})
        }

        sorted = Array(grouped.keys.enumerated())
            .sorted(by: ({$0.element.jid < $1.element.jid}))
    }

    private func actionMinimize() -> Void {
        minimized.toggle()
    }

    private func actionSettings() -> Void {
        isSettingsPresented.toggle()
    }

    private func actionOnChangeJob(job: Job?) -> Void {
        actionOnAppear()
    }
}

extension NotesWidget {
    struct Settings: View {
        private let title: String = "Widget Settings"

        @Binding public var minimizeAll: Bool

        var body: some View {
            ZStack(alignment: .leading) {
                Theme.base.opacity(0.3)

                VStack(alignment: .leading) {
                    FancySubTitle(text: title)
                    Toggle("Minimize all groups", isOn: $minimizeAll)
                    Spacer()
                    FancyDivider()
                }
                .padding()
            }
        }
    }
}
