//
//  ProjectsWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-05.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct ProjectsWidget: View {
    public let title: String = "Recent projects"

    @State private var minimized: Bool = false
    @State private var query: String = ""
    @State private var listItems: [Project] = []
    @State private var isSettingsPresented: Bool = false

    @FetchRequest public var resource: FetchedResults<Project>

    @Environment(\.managedObjectContext) var moc

    @AppStorage("widget.projects.showSearch") private var showSearch: Bool = true
    @AppStorage("widget.projects.showAll") private var showAll: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack {
                    FancyButtonv2(
                        text: "Minimize",
                        action: actionMinimize,
                        icon: minimized ? "plus" : "minus",
                        showLabel: false,
                        type: .clear
                    )
                    .frame(width: 30, height: 30)

                    Text(title)
                        .padding(.trailing, 10)
                    Spacer()

                    HStack {
                        FancyButtonv2(
                            text: "Settings",
                            action: actionSettings,
                            icon: "gear",
                            showLabel: false,
                            type: .clear
                        )
                        .frame(width: 30, height: 30)
                    }
                    .padding(5)
                }
                .background(Theme.base.opacity(0.2))
            }

            VStack {
                if !minimized {
                    if isSettingsPresented {
                        Settings(
                            showSearch: $showSearch,
                            showAll: $showAll
                        )
                    } else {
                        if showSearch {
                            SearchBar(text: $query, disabled: minimized, placeholder: "Search projects...")
                                .onChange(of: query, perform: actionOnSearch)
                        } else {
                            HStack {Spacer()}
                        }

                        VStack(alignment: .leading, spacing: 5) {
                            if listItems.count > 0 {
                                ForEach(listItems) { project in
                                    ProjectRowPlain(project: project)
                                }
                            } else {
                                SidebarItem(
                                    data: "No projects matching query",
                                    help: "No projects matching query",
                                    role: .important
                                )
                            }
                        }
                    }
                } else {
                    HStack {
                        Text("\(listItems.count) projects")
                        Spacer()
                    }
                }
            }
            .padding(8)
            .background(Theme.base.opacity(0.2))
        }
        .onAppear(perform: actionOnAppear)
        .onChange(of: showAll, perform: {_ in actionOnAppear()})
    }
}

extension ProjectsWidget {
    public init() {
        _resource = CoreDataProjects.fetchProjects()
    }

    private func getRecent() -> [Project] {
        var projects: [Project] = []

        if resource.count > 0 {
            if showAll {
                for item in resource {
                    projects.append(item)
                }
            } else {
                for item in resource[..<5] {
                    projects.append(item)
                }
            }
        }

        return projects
    }

    private func actionOnAppear() -> Void {
        setListItems(getRecent())
    }

    private func actionOnSearch(term: String) -> Void {
        if term.count > 3 {
            setListItems(
                resource.filter {
                    $0.name?.caseInsensitiveCompare(term) == .orderedSame
                    ||
                    (
                        $0.name?.contains(term) ?? false
                        ||
                        $0.name?.starts(with: term) ?? false
                    )
                }
            )
        } else {
            setListItems(getRecent())
        }
    }

    private func actionMinimize() -> Void {
        withAnimation {
            minimized.toggle()
        }
    }

    private func setListItems(_ list: [Project]) -> Void {
        listItems = list
    }

    private func actionSettings() -> Void {
        withAnimation {
            isSettingsPresented.toggle()
        }
    }

}

extension ProjectsWidget {
    struct Settings: View {
        private let title: String = "Widget Settings"

        @Binding public var showSearch: Bool
        @Binding public var showAll: Bool

        var body: some View {
            ZStack(alignment: .leading) {
                Theme.base.opacity(0.3)

                VStack(alignment: .leading) {
                    FancySubTitle(text: title)
                    Toggle("Show search bar", isOn: $showSearch)
                    Toggle("Show all projects", isOn: $showAll)
                    Spacer()
                    FancyDivider()
                }
                .padding()
            }
        }
    }
}
