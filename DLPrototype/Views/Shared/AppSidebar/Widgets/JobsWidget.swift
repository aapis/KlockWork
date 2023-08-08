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


                    Text(title)
                        .padding(.trailing, 10)
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
                                JobRowPlain(job: job)
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
    public init() {
        _resource = CoreDataJob.fetchAll()
    }

    private func getRecent() -> [Job] {
        var jobs: [Job] = []
        let max = 5

        if resource.count > 0 {
            if resource.count < max {
                for item in resource {
                    jobs.append(item)
                }
            } else {
                for item in resource[..<5] {
                    jobs.append(item)
                }
            }
        }

        return jobs
    }
    
    private func actionMinimize() -> Void {
        withAnimation {
            minimized.toggle()
        }
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