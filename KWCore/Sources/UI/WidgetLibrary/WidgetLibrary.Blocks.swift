//
//  WidgetLibrary.Blocks.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-28.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension WidgetLibrary.UI {
    public struct Blocks {
        struct Definition: View {
            @EnvironmentObject public var state: Navigation
            public var definition: TaxonomyTermDefinitions
            public var icon: String? = nil
            @State private var isHighlighted: Bool = false

            var body: some View {
                Button {
                    self.state.session.job = self.definition.job
                    self.state.session.project = self.state.session.job?.project
                    self.state.session.company = self.state.session.project?.company
                    self.state.session.definition = self.definition
                    self.state.to(.definitionDetail)
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Text(self.definition.definition ?? "Error: Missing definition")
                        Spacer()
                        if let icon = self.icon {
                            Image(systemName: icon)
                        }
                    }
                    .padding(8)
                    .background(self.isHighlighted ? (self.definition.job?.backgroundColor ?? Theme.rowColour).opacity(1) : (self.definition.job?.backgroundColor ?? Theme.rowColour).opacity(0.8)) // @TODO: refactor, this sucks
                    .foregroundStyle((self.definition.job?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base : Theme.lightWhite)
                }
                .buttonStyle(.plain)
                .useDefaultHover({ hover in self.isHighlighted = hover})
            }
        }

        struct Icon: View, Identifiable {
            @EnvironmentObject private var state: Navigation
            @AppStorage("widget.navigator.viewModeIndex") private var viewModeIndex: Int = 0
            public var id: UUID = UUID()
            public var type: EType
            public var text: String
            public var colour: Color
            @State private var isHighlighted: Bool = false

            var body: some View {
                VStack(alignment: .center, spacing: 0) {
                    ZStack(alignment: .center) {
                        (self.viewModeIndex == 0 ? Color.gray.opacity(self.isHighlighted ? 1 : 0.8) : self.colour.opacity(self.isHighlighted ? 1 : 0.8))
                        VStack(alignment: .center, spacing: 0) {
                            (self.isHighlighted ? self.type.selectedIcon : self.type.icon)
                                .symbolRenderingMode(.hierarchical)
                                .font(.largeTitle)
                                .foregroundStyle(self.viewModeIndex == 0 ? self.colour : .white)
                        }
                        Spacer()
                    }
                    .frame(height: 65)

                    ZStack(alignment: .center) {
                        (self.isHighlighted ? self.state.theme.tint : Theme.textBackground)
                        VStack(alignment: .center, spacing: 0) {
                            Text(self.text)
                                .font(.system(.title3, design: .monospaced))
                                .foregroundStyle(self.isHighlighted ? Theme.base : .gray)
                        }
                        .padding([.leading, .trailing], 4)
                    }
                    .frame(height: 25)
                }
                .frame(width: 65)
                .clipShape(.rect(cornerRadius: 5))
                .useDefaultHover({ hover in self.isHighlighted = hover })
            }
        }

        struct GenericBlock: View {
            @EnvironmentObject public var state: Navigation
            public var item: NSManagedObject
            @State private var bgColour: Color = .clear
            @State private var name: String = ""
            @State private var isHighlighted: Bool = false

            var body: some View {
                Button {
                    self.actionOnTap()
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Text(self.name)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding(8)
                    .background(self.isHighlighted ? self.bgColour.opacity(1) : self.bgColour.opacity(0.8))
                    .foregroundStyle(self.bgColour.isBright() ? Theme.base : Theme.lightWhite)
                    .clipShape(.rect(cornerRadius: 5))
                    .help(self.name)
                }
                .contextMenu {
                    Button {
                        ClipboardHelper.copy(self.bgColour.description)
                    } label: {
                        Text("Copy colour HEX to clipboard")
                    }
                }
                .buttonStyle(.plain)
                .useDefaultHover({ hover in self.isHighlighted = hover })
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.item) { self.actionOnAppear() }
            }
        }

        // MARK: Term
        struct Term: View {
            @EnvironmentObject public var state: Navigation
            public let term: TaxonomyTerm
            @State private var highlighted: Bool = false

            var body: some View {
                Button {
                    self.actionOnTap()
                } label: {
                    VStack(spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            Color.white
                                .shadow(color: .black.opacity(1), radius: 3)
                                .opacity(highlighted ? 0.2 : 0.1)
                            VStack(alignment: .leading, spacing: 10) {
                                Text(self.term.name ?? "_TERM_NAME")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .padding([.leading, .trailing, .top])
                                if let defs = self.term.definitions {
                                    if defs.count == 1 {
                                        Text("\(defs.count) Definition")
                                            .foregroundStyle(.white.opacity(0.55))
                                            .padding([.leading, .trailing, .bottom])
                                    } else {
                                        Text("\(defs.count) Definitions")
                                            .foregroundStyle(.white.opacity(0.55))
                                            .padding([.leading, .trailing, .bottom])
                                    }
                                }
                                Spacer()
                                UI.ResourcePath(
                                    company: self.state.session.job?.project?.company,
                                    project: self.state.session.job?.project,
                                    job: self.state.session.job
                                )
                            }
                        }
                    }
                }
                .frame(height: 150)
                .clipShape(.rect(cornerRadius: 5))
                .useDefaultHover({ inside in highlighted = inside})
                .buttonStyle(.plain)
            }
        }

        // MARK: DefinitionAlternative
        struct DefinitionAlternative: View {
            @EnvironmentObject public var state: Navigation
            public let definition: TaxonomyTermDefinitions
            @State private var highlighted: Bool = false

            var body: some View {
                Button {
                    self.actionOnTap()
                } label: {
                    VStack(spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            Color.white
                                .shadow(color: .black.opacity(1), radius: 3)
                                .opacity(highlighted ? 0.2 : 0.1)
                            VStack(alignment: .leading, spacing: 10) {
                                Text(self.definition.term?.name ?? "_TERM_NAME")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .padding([.leading, .trailing, .top])
                                Text(self.definitionBody())
                                    .foregroundStyle(.white.opacity(0.55))
                                    .padding([.leading, .trailing, .bottom])
                                Spacer()
                                UI.ResourcePath(
                                    company: self.state.session.job?.project?.company,
                                    project: self.state.session.job?.project,
                                    job: self.state.session.job
                                )
                            }
                        }
                    }
                }
                .frame(height: 150)
                .clipShape(.rect(cornerRadius: 5))
                .useDefaultHover({ inside in highlighted = inside})
                .buttonStyle(.plain)
            }
        }

        // MARK: Blocks.Day
        struct Day: View, Identifiable {
            @EnvironmentObject private var state: Navigation
            public let id: UUID = UUID()
            public var date: Date
            public var dayNumber: Int = 0
            public var isSelected: Bool = false
            public var isWeekend: Bool = false
            @State private var bgColour: Color = .clear
            @State private var fgColour: Color = .white
//            @State private var isPresented: Bool = false
            @State private var isHighlighted: Bool = false
            @State private var colourData: Set<Color> = []
            private let gridSize: CGFloat = 35
            private var isToday: Bool {Calendar.autoupdatingCurrent.isDateInToday(self.date)}

            var body: some View {
                Button {
                    self.state.session.date = DateHelper.startOfDay(self.date)
                } label: {
                    VStack(spacing: 0) {
                        VStack {
                            HStack {
                                Spacer()
                                Text(DateHelper.todayShort(self.date, format: "EEE dd"))
                                    .bold(self.isToday || self.isSelected)
                                    .padding([.top, .bottom], 4)
                                    .opacity(self.isToday ? 1 : 0.8)
                                Spacer()
                            }
                        }
                        .background(self.isSelected ? self.state.theme.tint : self.isToday ? .blue : Theme.textBackground)
                        ZStack {
                            (self.dayNumber > 0 ? self.bgColour.opacity(0.8) : .clear)
                            if self.dayNumber > 0 {
                                ZStack {
                                    // Jobs associated with tasks due on a given date provide
                                    VStack(alignment: .center, spacing: 0) {
                                        if self.colourData.count > 0 {
                                            ForEach(Array(self.colourData), id: \.self) { colour in
                                                Rectangle()
                                                    .foregroundStyle(self.isHighlighted ? colour.opacity(1) : colour.opacity(0.8))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        VStack {
                            HStack {
                                Spacer()
                                Text(DateHelper.todayShort(self.date, format: "MMMM"))
                                    .bold(self.isToday || self.isSelected)
                                    .padding([.top, .bottom], 4)
                                    .opacity(self.isToday ? 1 : 0.8)
                                Spacer()
                            }
                        }
                        .background(self.isSelected ? self.state.theme.tint : self.isToday ? .blue : .clear)
                    }
                    .background(Theme.textBackground)
                    .useDefaultHover({ hover in self.isHighlighted = hover })
                }
                .help("\(self.colourData.count) Tasks due on \(self.state.session.date.formatted(date: .abbreviated, time: .omitted))")
                .buttonStyle(.plain)
                .foregroundColor(self.fgColour)
                .clipShape(.rect(cornerRadius: 6))
                .onAppear(perform: self.actionOnAppear)
                .contextMenu {
                    Button {
                        self.state.to(.timeline)
                        self.state.session.date = self.date
                    } label: {
                        Text("Show Timeline...")
                    }
                    Button {
                        self.state.to(.today)
                        self.state.session.date = self.date
                    } label: {
                        Text("Show Today...")
                    }
                }
            }
        }
    }
}

extension WidgetLibrary.UI.Blocks.Day {
    /// Onload handler, determines tile back/foreground colours
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.bgColour = .clear
        self.fgColour = .white
        self.prepareColourData()

        if self.isToday && self.isSelected || self.isSelected {
            self.bgColour = self.state.theme.tint
            self.fgColour = Theme.base
        } else if self.isToday {
            self.bgColour = .blue
            self.fgColour = .white
        } else if self.date < Date() {
            self.fgColour = .gray
        }
    }

    /// Called in onload handler. Determines colour values for calendar Day border
    /// - Returns: Void
    private func prepareColourData() -> Void {
        self.colourData = []

        if let plan = CoreDataPlan(moc: self.state.moc).forDate(self.date).first {
            if let jobs = plan.jobs?.allObjects as? [Job] {
                for job in jobs.sorted(by: {$0.created ?? Date() < $1.created ?? Date()}) {
                    self.colourData.insert(job.backgroundColor)
                }
            }
        } else {
            let jobs = CoreDataTasks(moc: self.state.moc)
                .jobsForTasksDueToday(self.date)
                .sorted(by: {$0.created ?? Date() < $1.created ?? Date()})

            if !jobs.isEmpty {
                for job in jobs {
                    self.colourData.insert(job.backgroundColor)
                }
            } else {
                let records = CoreDataRecords(moc: self.state.moc).forDate(self.date)
                if !records.isEmpty {
                    for record in records {
                        if let colour = record.job?.backgroundColor {
                            self.colourData.insert(colour)
                        }
                    }
                }
            }
        }
    }
}

extension WidgetLibrary.UI.Blocks.Term {
    /// Fires when a term block is clicked/tapped
    /// - Returns: Void
    private func actionOnTap() -> Void {
        self.state.to(.termDetail)
        self.state.session.term = self.term
    }
}

extension WidgetLibrary.UI.Blocks.DefinitionAlternative {
    /// Trucate term answer
    /// - Returns: String
    private func definitionBody() -> String {
        if let body = self.definition.definition {
            if body.count > 100 {
                let i = body.index(body.startIndex, offsetBy: 100)
                let description = String(body[...i]).trimmingCharacters(in: .whitespacesAndNewlines)

                return description + "..."
            }
        }

        return "No preview available"
    }

    /// Fires when a term block is clicked/tapped
    /// - Returns: Void
    private func actionOnTap() -> Void {
        self.state.session.definition = self.definition
        self.state.to(.definitionDetail)
    }
}


extension WidgetLibrary.UI.Blocks.GenericBlock {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let job = self.item as? Job {
            self.bgColour = job.backgroundColor
            self.name = job.title ?? job.jid.string
        } else if let project = self.item as? Project {
            self.bgColour = project.backgroundColor
            self.name = "\(project.name ?? "Error: Invalid project name") (\(project.abbreviation ?? "YYY"))"
        } else if let company = self.item as? Company {
            self.bgColour = company.backgroundColor
            self.name = "\(company.name ?? "Error: Invalid company name") (\(company.abbreviation ?? "XXX"))"
        } else if let note = self.item as? Note {
            self.bgColour = note.mJob?.backgroundColor ?? Theme.rowColour
            self.name = note.mJob?.title ?? note.mJob?.jid.string ?? "Error: Invalid job title"
        } else if let task = self.item as? LogTask {
            self.bgColour = task.owner?.backgroundColor ?? Theme.rowColour
            self.name = "\(task.owner?.title ?? "Error: Invalid job title")"
        } else if let record = self.item as? LogRecord {
            self.bgColour = record.job?.backgroundColor ?? Theme.rowColour
            self.name = record.job?.title ?? "Error: Invalid job title"
        } else if let definition = self.item as? TaxonomyTermDefinitions {
            self.bgColour = definition.job?.backgroundColor ?? Theme.rowColour
            self.name = definition.job?.title ?? "Error: Invalid job title"
        }
    }

    /// Fires when a block is tapped
    /// - Returns: Void
    private func actionOnTap() -> Void {
        if let job = self.item as? Job {
            self.state.session.job = job
            self.state.session.project = job.project
            self.state.session.company = job.project?.company
            self.state.to(.jobs)
        } else if let project = self.item as? Project {
            self.state.session.project = project
            self.state.session.company = project.company
            self.state.to(.projectDetail)
        } else if let company = self.item as? Company {
            self.state.session.company = company
            self.state.to(.companyDetail)
        } else if let note = self.item as? Note {
            self.state.session.note = note
            self.state.to(.noteDetail)
        } else if let task = self.item as? LogTask {
            self.state.session.task = task
            self.state.to(.taskDetail)
        } else if let record = self.item as? LogRecord {
            self.state.session.date = record.timestamp ?? Date()
            self.state.to(.today)
        } else if let definition = self.item as? TaxonomyTermDefinitions {
            self.state.session.definition = definition
            self.state.to(.definitionDetail)
        }
    }
}
