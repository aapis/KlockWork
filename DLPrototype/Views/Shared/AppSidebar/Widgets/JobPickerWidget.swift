//
//  JobPickerWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-06.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct JobPickerWidget: View {
    public let title: String = "Recently Used Jobs"

    @State private var minimized: Bool = false
    @State private var query: String = ""
    @State private var listItems: [Job] = []
    @State private var grouped: Dictionary<Project, [Job]> = [:]
    @State private var isSettingsPresented: Bool = false

    @FetchRequest public var resource: FetchedResults<LogRecord>

    @AppStorage("widget.jobpicker.showSearch") private var showSearch: Bool = true
    @AppStorage("widget.jobpicker.minimizeAll") private var minimizeAll: Bool = false

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let parent = nav.parent {
                    if parent != .jobs {
                        FancySubTitle(text: title)
                    }
                }

                Spacer()
                FancyButtonv2(
                    text: "Settings",
                    action: actionSettings,
                    icon: "gear",
                    showLabel: false,
                    type: .white
                )
                .frame(width: 30, height: 30)

                FancyButtonv2(
                    text: "Minimize",
                    action: actionMinimize,
                    icon: minimized ? "plus" : "minus",
                    showLabel: false,
                    type: .white
                )
                .frame(width: 30, height: 30)
            }

            if !minimized {
                if isSettingsPresented {
                    Settings(
                        showSearch: $showSearch,
                        minimizeAll: $minimizeAll
                    )
                } else {
                    if showSearch {
                        VStack {
                            SearchBar(text: $query, disabled: minimized, placeholder: "Job ID or URL")
                                .onChange(of: query, perform: actionOnSearch)
                        }
                        
                        VStack(alignment: .leading, spacing: 0) {
                            if grouped.count > 0 {
                                ForEach(Array(grouped.keys.enumerated()), id: \.element) { index, key in
                                    JobProjectGroup(index: index, key: key, jobs: grouped)
                                }
                                FancyDivider()
                            } else {
                                SidebarItem(
                                    data: "No jobs matching query",
                                    help: "No jobs matching query",
                                    role: .important
                                )
                            }
                        }
                    }
                }
            }
        }
        .onAppear(perform: actionOnAppear)
    }
}

extension JobPickerWidget {
    public init() {
        _resource = CoreDataRecords.fetchRecent()
    }

    private func actionOnAppear() -> Void {
        let recent = CoreDataJob(moc: moc).getRecentlyUsed(records: resource)

        grouped = Dictionary(grouping: recent, by: {$0.project!})
    }

    private func actionSettings() -> Void {
        withAnimation {
            isSettingsPresented.toggle()
        }
    }

    private func actionMinimize() -> Void {
        withAnimation {
            minimized.toggle()
        }
    }

    private func actionOnSearch(term: String) -> Void {
        if term.count > 1 {
            var filtered = grouped.filter {
                (
                    $0.value.contains(where: {$0.jid.string.caseInsensitiveCompare(term) == .orderedSame})
                    ||
                    (
                        $0.value.contains(where: {$0.jid.string.starts(with: term)})
                    )
                )
            }

            if term.starts(with: "https://") { 
                filtered = grouped.filter {
                    (
                        $0.value.contains(where: {$0.uri?.absoluteString.caseInsensitiveCompare(term) == .orderedSame})
                        ||
                        (
                            $0.value.contains(where: {$0.uri?.absoluteString.contains(term) ?? false})
                            ||
                            $0.value.contains(where: {$0.uri?.absoluteString.starts(with: term) ?? false})
                        )
                    )
                }
            }

            grouped = filtered
        } else {
            actionOnAppear()
        }
    }
}

extension JobPickerWidget {
    struct Settings: View {
        private let title: String = "Widget Settings"

        @Binding public var showSearch: Bool
        @Binding public var minimizeAll: Bool

        var body: some View {
            ZStack(alignment: .leading) {
                Theme.base.opacity(0.3)

                VStack(alignment: .leading) {
                    FancySubTitle(text: title)
                    Toggle("Show search bar", isOn: $showSearch)
                    Toggle("Minimize all groups", isOn: $minimizeAll)
                    Spacer()
                    FancyDivider()
                }
                .padding()
            }
        }
    }
}
