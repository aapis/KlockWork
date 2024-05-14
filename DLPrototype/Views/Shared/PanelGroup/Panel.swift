//
//  PanelGroup.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-01-04.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

// @TODO: refactor everything
public struct Panel {
    public enum Orientation {
        case horizontal, vertical
    }
    
    public enum Position {
        case first, middle, last
    }
    
    public struct SelectedValueCoordinates: Equatable {
        var position: Position
        var item: NSManagedObject
    }
    
    public struct RowConfiguration {
        var text: String
        var action: () -> Void
        var entity: NSManagedObject
        var position: Panel.Position
        var special: Bool = false
        var specialIcon: String = ""
    }
    
    struct Row: View {
        public var config: RowConfiguration

        @EnvironmentObject private var nav: Navigation

        var body: some View {
            FancySimpleButton(
                text: config.text,
                action: fireCallback,
                labelView: AnyView(
                    HStack {
                        if config.special {
                            Image(systemName: config.specialIcon)
                                .help("This is your default company. Change this in Settings")
                        }
                        Text(config.text)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .opacity(config.position == .last ? 0 : 1)
                    }
                    .padding(10)
                    .background(nav.forms.tp.selected.contains(where: {$0.item == config.entity}) ? .orange : .clear)
                    .foregroundStyle(nav.forms.tp.selected.contains(where: {$0.item == config.entity}) ? .black : .white)
                ),
                size: .link,
                type: .clear
            )
            .border(width: 1, edges: [.top], color: Theme.rowColour)
        }
    }
}

extension Panel.Row {
    /// Fire the callback INTO THE SUN
    /// - Returns: Void
    private func fireCallback() -> Void {
        highlightPanelEntity(Panel.SelectedValueCoordinates(position: config.position, item: config.entity))
        config.action()
    }

    /// Changes which entity is highlighted in each column
    /// - Returns: Void
    private func highlightPanelEntity(_ selected: Panel.SelectedValueCoordinates) -> Void {
        var items = nav.forms.tp.selected
        if items.isEmpty {
            items.append(selected)
        } else {
            if !items.contains(where: {$0.position == config.position}) {
                items.append(selected)
            } else {
                for (offset, _) in items.enumerated() {
                    if items[offset].position == config.position {
                        items[offset].item = config.entity
                    }
                }
            }
        }

        nav.forms.tp.selected = items
    }
}

struct CompanyPanel: View {
    public var position: Panel.Position

    @AppStorage("CreateEntitiesWidget.isSearching") private var isSearching: Bool = false

    @State private var showSearch: Bool = false
    @State private var searchText: String = ""

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(alignment: .center) {
                Text("Companies").font(.title3)
                Spacer()
                // @TODO: uncomment and implement search
//                FancySimpleButton(
//                    text: "Search",
//                    action: {showSearch.toggle()},
//                    icon: "magnifyingglass",
//                    showLabel: false,
//                    showIcon: true,
//                    type: .clear
//                )
                FancySimpleButton(
                    text: "Close",
                    action: closePanel,
                    icon: "xmark",
                    showLabel: false,
                    showIcon: true
                )
            }
            .padding(10)
            
            if showSearch {
                SearchBar(text: $searchText, onSubmit: search)
            }

            if let firstColData = nav.forms.tp.first {
                if position == .first {
                    VStack(alignment: .leading, spacing: 1) {
                        if !firstColData.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 1) {
                                    ForEach(firstColData) { company in
                                        Panel.Row(
                                            config: Panel.RowConfiguration(
                                                text: company.name?.capitalized ?? "_COMPANY_NAME",
                                                action: {setMiddlePanel(data: company.projects!.allObjects)},
                                                entity: company,
                                                position: position,
                                                special: company.isDefault,
                                                specialIcon: "building.2"
                                            )
                                        )
                                        .contextMenu {
                                            Button(action: {
                                                isSearching.toggle() // doesn't work :(((
                                                if let name = company.name {
                                                    nav.session.search.text = name
                                                };

                                                nav.session.search.inspect(company)
                                            }, label: {
                                                Text("Inspect")
                                            })
                                        }
                                    }
                                }
                            }
                        } else {
                            Text("No companies found")
                                .padding(10)
                        }
                        Spacer()
                    }
                } else if position == .middle {
                    VStack(alignment: .leading, spacing: 1) {
                        if !nav.forms.tp.middle.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 1) {
                                    ForEach(nav.forms.tp.middle) { project in
                                        Panel.Row(
                                            config: Panel.RowConfiguration(
                                                text: project.name!.capitalized,
                                                action: {setLastPanel(data: project.jobs!.allObjects)},
                                                entity: project,
                                                position: position
                                            )
                                        )
                                    }
                                }
                            }
                        } else {
                            Text("No company selected, or company has no projects")
                                .padding(10)
                        }
                        Spacer()
                    }
                } else if position == .last {
                    VStack(alignment: .leading, spacing: 1) {
                        if !nav.forms.tp.last.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 1) {
                                    ForEach(nav.forms.tp.last, id: \.objectID) { job in
                                        let job = job as! Job
                                        Panel.Row(
                                            config: Panel.RowConfiguration(
                                                text: job.title?.capitalized ?? job.jid.string,
                                                action: {nav.session.job = job},
                                                entity: job,
                                                position: position
                                            )
                                        )
                                    }
                                }
                            }
                        } else {
                            Text("No job selected, or project has no jobs")
                                .padding(10)
                        }
                        Spacer()
                    }
                }
            }
        }
        .background(Theme.rowColour)
        .frame(height: 300)
    }
}

extension CompanyPanel {
    private func setMiddlePanel(data: [Any]) -> Void {
        nav.forms.tp.currentPosition = position
        nav.forms.tp.middle = (data as! [Project]).sorted(by: {$0.name! < $1.name!})
        nav.forms.tp.last = []
        nav.session.job = nil
    }
    
    private func setLastPanel(data: [Any]) -> Void {
        nav.forms.tp.currentPosition = position
        nav.forms.tp.last = (data as! [Job]).sorted(by: {$0.jid < $1.jid})
    }
    
    private func closePanel() -> Void {
        if position == .first {
            nav.forms.tp.middle = []
            nav.forms.tp.last = []
            nav.forms.tp.selected = []
        } else if position == .middle {
            nav.forms.tp.middle = []
            nav.forms.tp.last = []
        } else if position == .last {
            nav.forms.tp.last = []
        }
        
        nav.session.job = nil
        showSearch = false
    }
    
    private func search() -> Void {
        
    }
}

struct ProjectPanel: View {
    public var position: Panel.Position
    
    @State private var showSearch: Bool = false
    @State private var searchText: String = ""

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(alignment: .center) {
                Text("Projects").font(.title3)
                Spacer()
                // @TODO: uncomment and implement search
//                FancySimpleButton(
//                    text: "Search",
//                    action: {showSearch.toggle()},
//                    icon: "magnifyingglass",
//                    showLabel: false,
//                    showIcon: true,
//                    type: .clear
//                )
//                .disabled(nav.forms.tp.middle.isEmpty)
//                .opacity(nav.forms.tp.middle.isEmpty ? 0.4 : 1)
                FancySimpleButton(
                    text: "Close",
                    action: closePanel,
                    icon: "xmark",
                    showLabel: false,
                    showIcon: true
                )
                .disabled(nav.forms.tp.middle.isEmpty || nav.forms.tp.middle.isEmpty)
                .opacity(nav.forms.tp.middle.isEmpty || nav.forms.tp.middle.isEmpty ? 0.4 : 1)
            }
            .padding(10)
            
            if showSearch {
                SearchBar(text: $searchText)
            }

            if let _ = nav.forms.tp.first {
                VStack(alignment: .leading, spacing: 1) {
                    if !nav.forms.tp.middle.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 1) {
                                ForEach(nav.forms.tp.middle) { project in
                                    Panel.Row(
                                        config: Panel.RowConfiguration(
                                            text: project.name!,
                                            action: {setLastPanel(project: project)},
                                            entity: project,
                                            position: position
                                        )
                                    )
                                }
                            }
                        }
                    } else {
                        Text("No company selected, or company has no projects")
                            .padding(10)
                    }
                    Spacer()
                }
            }
        }
        .background(nav.forms.tp.middle.isEmpty || nav.forms.tp.middle.isEmpty ? .black.opacity(0.1) : Theme.rowColour)
        .foregroundStyle(nav.forms.tp.middle.isEmpty || nav.forms.tp.middle.isEmpty ? .white.opacity(0.4) : .white)
        .frame(height: 300)
    }
}

extension ProjectPanel {
    private func setLastPanel(project: Project) -> Void {
        let jobs = project.jobs!.allObjects as! [Job]

        if nav.parent == .jobs {
            nav.forms.tp.currentPosition = position
            nav.forms.tp.last = jobs.sorted(by: {$0.jid < $1.jid})
        } else if nav.parent == .notes {
            var notes: [Note] = []

            for job in jobs {
                notes += job.mNotes?.allObjects as! [Note]
            }

            nav.forms.tp.currentPosition = position
            nav.forms.tp.last = notes.sorted(by: {$0.title?.count ?? 0 < $1.title?.count ?? 0})
        }
    }

    private func closePanel() -> Void {
        if position == .first {
            nav.forms.tp.middle = []
            nav.forms.tp.last = []
            nav.forms.tp.selected = []
        } else if position == .middle {
            nav.forms.tp.middle = []
            nav.forms.tp.last = []
        } else if position == .last {
            nav.forms.tp.last = []
        }
        
        nav.session.job = nil
        showSearch = false
    }
}

public struct JobPanel: View {
    public var position: Panel.Position
    
    @State private var showSearch: Bool = false
    @State private var searchText: String = ""

    @EnvironmentObject public var nav: Navigation

    public var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(alignment: .center) {
                Text("Jobs").font(.title3)
                Spacer()
                // @TODO: uncomment and implement search
//                FancySimpleButton(
//                    text: "Search",
//                    action: {showSearch.toggle()},
//                    icon: "magnifyingglass",
//                    showLabel: false,
//                    showIcon: true,
//                    type: .clear
//                )
//                .disabled(nav.forms.tp.last.isEmpty)
//                .opacity(nav.forms.tp.last.isEmpty ? 0.4 : 1)
                FancySimpleButton(
                    text: "Close",
                    action: closePanel,
                    icon: "xmark",
                    showLabel: false,
                    showIcon: true
                )
                .disabled(nav.forms.tp.last.isEmpty)
                .opacity(nav.forms.tp.last.isEmpty ? 0.4 : 1)
            }
            .padding(10)
            
            if showSearch {
                SearchBar(text: $searchText)
            }

            if let _ = nav.forms.tp.first {
                VStack(alignment: .leading, spacing: 1) {
                    if !nav.forms.tp.last.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 1) {
                                ForEach(nav.forms.tp.last, id: \.objectID) { job in
                                    let job = job as! Job
                                    Panel.Row(
                                        config: Panel.RowConfiguration(
                                            text: job.title?.capitalized ?? job.jid.string,
                                            action: {nav.session.job = job},
                                            entity: job,
                                            position: position
                                        )
                                    )
                                }
                            }
                        }
                    } else {
                        Text("No jobs found")
                            .padding(10)
                    }
                    Spacer()
                }
            }
        }
        .background(nav.forms.tp.last.isEmpty ? .black.opacity(0.1) : Theme.rowColour)
        .foregroundStyle(nav.forms.tp.last.isEmpty ? .white.opacity(0.4) : .white)
        .frame(height: 300)
    }
}

extension JobPanel {
    private func closePanel() -> Void {
        if position == .first {
            nav.forms.tp.middle = []
            nav.forms.tp.last = []
            nav.forms.tp.selected = []
        } else if position == .middle {
            nav.forms.tp.middle = []
            nav.forms.tp.last = []
        } else if position == .last {
            nav.forms.tp.last = []
        }
        
        nav.session.job = nil
        showSearch = false
    }
}

public struct NotePanel: View {
    public var position: Panel.Position

    @State private var showSearch: Bool = false
    @State private var searchText: String = ""

    @EnvironmentObject public var nav: Navigation

    public var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(alignment: .center) {
                Text("Notes").font(.title3)
                Spacer()
                // @TODO: uncomment and implement search
//                FancySimpleButton(
//                    text: "Search",
//                    action: {showSearch.toggle()},
//                    icon: "magnifyingglass",
//                    showLabel: false,
//                    showIcon: true,
//                    type: .clear
//                )
//                .disabled(nav.forms.tp.last.isEmpty)
//                .opacity(nav.forms.tp.last.isEmpty ? 0.4 : 1)
                FancySimpleButton(
                    text: "Close",
                    action: closePanel,
                    icon: "xmark",
                    showLabel: false,
                    showIcon: true
                )
                .disabled(nav.forms.tp.last.isEmpty)
                .opacity(nav.forms.tp.last.isEmpty ? 0.4 : 1)
            }
            .padding(10)

            if showSearch {
                SearchBar(text: $searchText)
            }

            if let _ = nav.forms.tp.first {
                VStack(alignment: .leading, spacing: 1) {
                    if !nav.forms.tp.last.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 1) {
                                ForEach(nav.forms.tp.last, id: \.objectID) { note in
                                    let note = note as! Note
                                    Panel.Row(
                                        config: Panel.RowConfiguration(
                                            text: note.title ?? "_NOTE_TITLE",
                                            action: {
                                                nav.view = AnyView(NoteCreate(note: note))
                                                nav.parent = .notes
                                                nav.sidebar = AnyView(NoteCreateSidebar(note: note))
                                                nav.pageId = UUID()
                                            },
                                            entity: note,
                                            position: position
                                        )
                                    )
                                }
                            }
                        }
                    } else {
                        Text("No notes found")
                            .padding(10)
                    }
                    Spacer()
                }
            }
        }
        .background(nav.forms.tp.last.isEmpty ? .black.opacity(0.1) : Theme.rowColour)
        .foregroundStyle(nav.forms.tp.last.isEmpty ? .white.opacity(0.4) : .white)
        .frame(height: 300)
    }
}

extension NotePanel {
    private func closePanel() -> Void {
        if position == .first {
            nav.forms.tp.middle = []
            nav.forms.tp.last = []
            nav.forms.tp.selected = []
        } else if position == .middle {
            nav.forms.tp.middle = []
            nav.forms.tp.last = []
        } else if position == .last {
            nav.forms.tp.last = []
        }

//        nav.session.job = nil
        showSearch = false
    }
}
