//
//  JobPickerWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-06.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct JobPickerWidget: View {
    public var title: String = "Recent Jobs"
    public var location: WidgetLocation = .sidebar

    @State private var minimized: Bool = false
    @State private var query: String = ""
    @State private var grouped: Dictionary<Project, [Job]> = [:]
    @State private var sgrouped: Dictionary<Project, [Job]> = [:]
    @State private var isSettingsPresented: Bool = false
    @State private var isLoading: Bool = false
    @State private var sorted: [EnumeratedSequence<Dictionary<Project, [Job]>.Keys>.Element] = []

    @FetchRequest public var resource: FetchedResults<LogRecord>

    @AppStorage("widget.jobpicker.showSearch") private var showSearch: Bool = true
    @AppStorage("widget.jobpicker.minimizeAll") private var minimizeAll: Bool = false
    @AppStorage("widget.jobpicker.onlyRecent") private var onlyRecent: Bool = true

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        if isLoading {
            WidgetLoading()
        } else {
            JobPickerWidget
        }
    }

    var JobPickerWidget: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack {
                    if location == .sidebar {
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
                        
                    } else {
                        Text(title)
                            .padding(10)
                        Spacer()
                    }
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
                                    JobProjectGroup(index: index, key: key, jobs: grouped, location: location)
                                }
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
            .padding(8)
            .background(Theme.base.opacity(0.2))
        }
        .onAppear(perform: actionOnAppear)
    }
}

extension JobPickerWidget {
    public init(location: WidgetLocation? = nil) {
        _resource = CoreDataRecords.fetchRecent()

        if let loc = location {
            self.location = loc
        }
    }

    private func actionOnAppear() -> Void {
        if nav.session.gif == .focus {
            if let plan = nav.session.plan {
                if let setJobs = plan.jobs {
                    let jobs = setJobs.allObjects as! [Job]
                    query = jobs.map({$0.jid.string}).joined(separator: ", ")
                    grouped = Dictionary(grouping: jobs, by: {$0.project!})
                }
            }
        } else {
            let recent = CoreDataJob(moc: moc).getRecentlyUsed(records: resource)
            grouped = Dictionary(grouping: recent.filter {$0.alive == true && $0.project != nil}, by: {$0.project!})
        }

        sorted = Array(grouped.keys.enumerated())
            .sorted(by: ({$0.element.pid < $1.element.pid}))
    }

    private func actionMinimize() -> Void {
        // only allow when widget is installed on a sidebar
        if location == .sidebar {
            minimized.toggle()
        }
    }

    private func actionSettings() -> Void {
        // only allow when widget is installed on a sidebar
        if location == .sidebar {
            isSettingsPresented.toggle()
        }
    }

    private func actionOnChangeJob(job: Job?) -> Void {
        actionOnAppear()
    }
}

extension JobPickerWidget {
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
