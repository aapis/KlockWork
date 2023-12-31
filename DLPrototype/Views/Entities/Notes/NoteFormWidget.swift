//
//  NoteFormWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct NoteFormWidget: View {
    @State private var selection: Int = 0
    @State private var allowChangeTemplate: Bool = false
    @State private var created: Date = Date()
    @State private var jobSearchText: String = ""
    @State private var filteredJobs: [Job] = []

    @EnvironmentObject private var nav: Navigation

    private var templates: NoteTemplates { NoteTemplates() }
    @FetchRequest private var jobs: FetchedResults<Job>

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("New Note")
                    .font(.title3)
                Spacer()
            }
            Divider()

            ForEach(NoteTemplates.Template.allCases, id: \.id) { config in
                Text(config.definition.name)
            }

//            Picker("Template:", selection: $selection) {
//                ForEach(NoteTemplates.Template.allCases, id: \.id) { config in
//                    Text(config.definition.name)
//                }
//            }
//            .alert("Changing templates will override your existing note content.\n\nAre you sure?", isPresented: $allowChangeTemplate) {
//                Button("Yes", role: .destructive) {
//                    nav.forms.note.template = NoteTemplates.Template.allCases[selection].definition.template
//                }
//                Button("No", role: .cancel) {}
//            }
//            Divider()

            HStack(alignment: .top) {
                Text("Date:")
                Text(nav.session.date.formatted(date: .complete, time: .omitted))
                    .help("Tip: Use the date navigation keyboard shortcuts (cmd+left/right arrow), or date selector above, to change this date")
            }
            Divider()

            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    if let job = nav.forms.note.job {
                        FancyButtonv2(
                            text: "Last selected job: \(job.jid.string)",
                            action: {nav.forms.note.job = nil},
                            fgColour: job.foregroundColor,
                            showLabel: true,
                            showIcon: false,
                            size: .link,
                            type: .clear
                        )
                        .help("Click to deselect this job, then show the Active Job prompt (if available)")
                        .padding(5)
                        .background(job.backgroundColor)
                    } else if let job = nav.session.job {
                        FancyButtonv2(
                            text: "Active job: \(job.jid.string)",
                            action: {nav.session.job = nil},
                            fgColour: job.foregroundColor,
                            showLabel: true,
                            showIcon: false,
                            size: .link,
                            type: .clear
                        )
                        .help("Click to deselect this job")
                        .padding(5)
                        .background(job.backgroundColor)
                    } else {
                        HStack {
                            Text("No job selected")
                                .padding(3)
                                .opacity(0.4)
                            Spacer()
                        }
                        .padding(5)
                        .background(Theme.cRed)
                    }
                }
                SearchBar(text: $jobSearchText, placeholder: "Find jobs by ID...")

                VStack(spacing: 1) {
                    ForEach(filteredJobs) { job in
                        FancyButtonv2(
                            text: job.jid.string,
                            action: {choose(job)},
                            fgColour: job.foregroundColor,
                            showLabel: true,
                            showIcon: false,
                            size: .link,
                            type: .clear
                        )
                        .padding(5)
                        .background(job.backgroundColor)
                    }
                }
            }
            Divider()
            FancyDivider()

            HStack {
                FancySimpleButton(text: "Cancel", type: .clear, href: .notes)
                Spacer()
                FancySimpleButton(text: "Create", action: {nav.saved = true}, type: .primary)
                    .keyboardShortcut("s", modifiers: .command)
            }

        }
        .padding(8)
        .background(Theme.base.opacity(0.2))
        .onChange(of: selection) { newSelection in
            allowChangeTemplate = true
        }
        .onChange(of: jobSearchText) { query in
            if query.count >= 2 {
                filteredJobs = jobs.filter {$0.jid.string.starts(with: query)}
            } else {
                filteredJobs = []
            }
        }
    }

    init() {
        _jobs = CoreDataJob.fetchAll()
    }
}

extension NoteFormWidget {
    private func choose(_ job: Job) -> Void {
        nav.forms.note.job = job
        jobSearchText = ""
    }
}
