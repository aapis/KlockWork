//
//  RecentJobsWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct JobsWidget: View {
    public let title: String = "Search Jobs"
    public var location: WidgetLocation = .sidebar

    @State private var minimized: Bool = false
    @State private var query: String = ""
    @State private var listItems: [Job] = []

    @FetchRequest public var resource: FetchedResults<Job>

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

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

                    if let parent = nav.parent {
                        if parent != .jobs {
                            Text(title)
                                .padding(.trailing, 10)
                        } else {
                            Text("Search all jobs")
                        }
                    }

                    Spacer()
                }
                .padding(5)
            }
            .background(Theme.base.opacity(0.2))

            VStack {
                if !minimized {
                    VStack {
                        SearchBar(text: $query, disabled: minimized, placeholder: "Job ID or URL")
                            .onChange(of: query, perform: actionOnSearch)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        if listItems.count > 0 {
                            ForEach(listItems) { job in
                                JobRowPlain(job: job, location: location)
                            }
                        } else {
                            SidebarItem(
                                data: "No jobs matching query",
                                help: "No jobs matching query",
                                role: .important
                            )
                        }
                    }
                } else {
                    HStack {
                        Text("\(listItems.count) jobs")
                        Spacer()
                    }
                }
            }
            .padding(8)
            .background(Theme.base.opacity(0.2))
        }
        .onAppear(perform: actionOnAppear)
    }
}

extension JobsWidget {
    public init(location: WidgetLocation? = nil) {
        _resource = CoreDataJob.fetchAll()
        
        if let loc = location {
            self.location = loc
        }
    }

    private func getRecent() -> [Job] {
        var jobs: [Job] = []
        let max = 15

        if resource.count > 0 {
            if resource.count <= max {
                for item in resource {
                    jobs.append(item)
                }
            } else {
                for item in resource[..<max] {
                    jobs.append(item)
                }
            }
        }

        return jobs
    }
    
    private func actionMinimize() -> Void {
        minimized.toggle()
    }

    private func actionSettings() -> Void {
//        isSettingsPresented.toggle()
    }

    private func actionOnAppear() -> Void {
        setListItems(getRecent())
    }

    private func actionOnSearch(term: String) -> Void {
        if term.count > 1 {
            setListItems(
                resource.filter {
                    (
                        $0.jid.string.caseInsensitiveCompare(term) == .orderedSame
                        ||
                        (
                            $0.jid.string.contains(term)
                            ||
                            $0.jid.string.starts(with: term)
                        )
                    )
                    ||
                    (
                        $0.uri?.absoluteString.caseInsensitiveCompare(term) == .orderedSame
                        ||
                        (
                            $0.uri?.absoluteString.contains(term) ?? false
                            ||
                            $0.uri?.absoluteString.starts(with: term) ?? false
                        )
                    )
                }
            )
        } else {
            setListItems(getRecent())
        }
    }

    private func setListItems(_ list: [Job]) -> Void {
        listItems = list
    }
}
