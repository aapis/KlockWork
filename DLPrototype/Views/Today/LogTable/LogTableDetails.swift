//
//  LogTableDetails.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import EventKit

protocol Statistics: Identifiable {
    var key: String {get set}
    var value: String {get set}
    var colour: Color {get set}
    var group: StatisticPeriod {get set}
    var view: AnyView? {get set}
    var linkAble: Bool? {get set}
    var linkTarget: Note? {get set}
    var id: UUID {get set}
}

struct Statistic: Statistics {
    public var key: String
    public var value: String
    public var colour: Color
    public var group: StatisticPeriod
    public var view: AnyView?
    public var linkAble: Bool? = false
    public var linkTarget: Note?
    public var id = UUID()
}

struct StatisticWithView: Statistics {
    public var key: String
    public var value: String
    public var colour: Color
    public var group: StatisticPeriod
    public var view: AnyView?
    public var linkAble: Bool? = false
    public var linkTarget: Note?
    public var id = UUID()
}

struct StatisticGroup: Identifiable {
    public let title: String
    public let enumKey: StatisticPeriod
    public let id = UUID()
}

public enum StatisticPeriod: String, CaseIterable {
    case today = "Today"
    case notes = "Notes"
    case overall = "Overall"
    case jobs = "Jobs"
    case tasks = "Tasks"
    case upcomingEvents = "Upcoming Events"
    case currentEvents = "Events In Progress"
}

struct LogTableDetails: View {
    @Binding public var records: [LogRecord]
    @Binding public var selectedDate: Date
    @Binding public var open: Bool
    @Binding public var selectedTab: Tab
    
    @State private var statistics: [any Statistics] = []
    @State private var inProgressEvents: [EKEvent] = []
    @State private var upcomingEvents: [EKEvent] = []
    
    static public var groups: [StatisticGroup] = [
        StatisticGroup(title: "Viewing", enumKey: .today),
        StatisticGroup(title: StatisticPeriod.overall.rawValue, enumKey: .overall),
        StatisticGroup(title: StatisticPeriod.currentEvents.rawValue, enumKey: .currentEvents),
        StatisticGroup(title: StatisticPeriod.upcomingEvents.rawValue, enumKey: .upcomingEvents),
        StatisticGroup(title: StatisticPeriod.notes.rawValue, enumKey: .notes),
        StatisticGroup(title: StatisticPeriod.tasks.rawValue, enumKey: .tasks),
        StatisticGroup(title: StatisticPeriod.jobs.rawValue, enumKey: .jobs)
    ]

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var jm: CoreDataJob
    @EnvironmentObject public var ce: CoreDataCalendarEvent

    
    
    private var notes: [Note] {
        CoreDataNotes(moc: moc).forDate(selectedDate)
    }
    
    private var tasks: [LogTask] {
        CoreDataTasks(moc: moc).forDate(selectedDate, from: records)
    }
    
    var body: some View {
        Section {
            Grid(alignment: .top, horizontalSpacing: 1, verticalSpacing: 1) {
                header
                    .font(Theme.font)
                
                ScrollView {
                    rows.font(Theme.font)
                }
                .id(updater.ids["ltd.rows"])
            }
        }
    }
    
    var header: some View {
        GridRow {
            Group {
                ZStack(alignment: .leading) {
                    Theme.headerColour
                    Text("Statistics & Information")
                        .padding(10)
                }
            }
        }
        .frame(height: 40)
    }
    
    var rows: some View {
        GridRow {
            VStack(alignment: .leading, spacing: 1) {
                if statistics.count > 0 && records.count > 0 {
                    ForEach(LogTableDetails.groups) { group in
                        let children = statistics.filter({ $0.group == group.enumKey})
                        
                        if children.count > 0 {
                            VStack(alignment: .leading) {
                                if group.enumKey == .today {
                                    DetailGroup(name: group.title, children: children, subTitle: DateHelper.dateFromRecord(records.first!))
                                        .environmentObject(updater)
                                } else {
                                    DetailGroup(name: group.title, children: children)
                                        .environmentObject(updater)
                                }
                            }
                        }
                    }
                } else {
                    LogRowEmpty(message: "No stats", index: 0, colour: Theme.rowColour)
                }
            }
            .onChange(of: records) { _ in
                update()
            }
            .onChange(of: tasks) { _ in
                update()
            }
            .onChange(of: notes) { _ in
                update()
            }
        }
        .onAppear(perform: update)
        .onAppear(perform: setTimers)
    }

    private func setTimers() -> Void {
        func _setStateEventData() -> Void {
            ce.truncate()
            
            if let chosenCalendar = ce.selectedCalendar() {
                inProgressEvents = ce.eventsInProgress(chosenCalendar)
                upcomingEvents = ce.eventsUpcoming(chosenCalendar)
            }
        }

        _setStateEventData()

        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            _setStateEventData()
            updater.update()
        }
    }
    
    private func update() -> Void {
        setTimers() // start timers whether sidebar is open or not (may be a really bad idea we will see)

        if records.count > 0 && open {
            statistics = []
            
            for record in records {
                if record.job != nil {
                    let colour = Color.fromStored(record.job?.colour ?? Theme.rowColourAsDouble)
                    
                    if !statistics.contains(where: {$0.value == "\(colour)"}) {
                        statistics.append(
                            StatisticWithView(
                                key: record.job?.jid.string ?? "No ID",
                                value: "\(colour)",
                                colour: colour,
                                group: .jobs,
                                view: AnyView(JobRow(job: record.job!, colour: colour).environmentObject(jm))
                            )
                        )
                    }
                }
            }
            
            // Number of records in the set
            statistics.append(Statistic(key: "Records in set", value: String(records.count), colour: Theme.rowColour, group: .today))
            statistics.append(Statistic(key: "View description", value: selectedTab.description, colour: Theme.rowColour, group: .today))
            // Word count in the current set
            statistics.append(Statistic(key: "Word count", value: String(wordCount()), colour: Theme.rowColour, group: .overall))

            // upcoming events
            for event in upcomingEvents {
                statistics.append(
                    StatisticWithView(
                        key: event.title,
                        value: event.title,
                        colour: Theme.rowColour,
                        group: .upcomingEvents,
                        view: AnyView (EventRow(event: event))
                    )
                )
            }
            // in progress events
            for event in inProgressEvents {
                statistics.append(
                    StatisticWithView(
                        key: event.title,
                        value: event.title,
                        colour: Theme.rowStatusGreen,
                        group: .currentEvents,
                        view: AnyView (EventRow(event: event))
                    )
                )
            }

            
            // Note list and count
            if notes.count > 0 {
                for note in notes {
                    statistics.append(
                        StatisticWithView(
                            key: note.title!,
                            value: note.id!.debugDescription,
                            colour: Color.fromStored(note.mJob?.colour ?? Theme.rowColourAsDouble),
                            group: .notes,
                            view: AnyView(
                                NavigationLink {
                                    NoteView(note: note)
                                        .navigationTitle("Viewing \(note.title!)")
                                        .environmentObject(jm)
                                        .environmentObject(updater)
                                } label: {
                                    VStack(alignment: .leading) {
                                        ZStack(alignment: .leading) {
                                            Color.clear
                                            HStack(alignment: .top, spacing: 0) {
                                                Image(systemName: "link")
                                                    .padding([.leading], 5)
                                                Text(note.title!)
                                                    .padding([.leading], 5)
                                            }
                                        }
                                        .frame(height: 30)
                                    }
                                }
                                    .help(note.title!)
                                    .buttonStyle(.borderless)
                                    .padding(5)
                                    .onHover { inside in
                                        if inside {
                                            NSCursor.pointingHand.push()
                                        } else {
                                            NSCursor.pop()
                                        }
                                    }
                            )
                        )
                    )
                }
            }
            
            // Task list and count
            if tasks.count > 0 {
                for task in tasks {
                    statistics.append(
                        StatisticWithView(
                            key: task.owner?.jid.string ?? "No owner",
                            value: task.content ?? "No content",
                            colour: Color.clear,
                            group: .tasks,
                            view: AnyView(TaskView(task: task, colourizeRow: true))
                        )
                    )
                }
            }
        }
    }
    
    private func wordCount() -> Int {
        var words: [String] = []
        
        for item in records {
            words.append(item.message!)
        }
        
        let wordSet: Set = Set(words.joined(separator: " ").split(separator: " "))
        
        return wordSet.count + noteWordCount()
    }
    
    private func noteWordCount() -> Int {
        var words: [String] = []
        
        for item in notes {
            words.append(item.body!)
        }
        
        let wordSet: Set = Set(words.joined(separator: " ").split(separator: " "))
        
        return wordSet.count
    }
}

struct LogTableDetailsPreview: PreviewProvider {
    @State static private var selectedDate: Date = Date()
    @State static private var records: [LogRecord] = []
    @State static private var open: Bool = true
    @State static private var selectedTab: Tab = .chronologic
    
    static var previews: some View {
        LogTableDetails(records: $records, selectedDate: $selectedDate, open: $open, selectedTab: $selectedTab)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
