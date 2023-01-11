//
//  LogTableDetails.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

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
}

struct LogTableDetails: View {
    @Binding public var records: [LogRecord]
    @Binding public var selectedDate: Date
    
    @State private var statistics: [any Statistics] = []
    
    static public var groups: [StatisticGroup] = [ // TODO: I tried to pull these from the enum but it was so FUCKING FRUSTRATING that I almost yeeted the codebase into the sun
        StatisticGroup(title: "Viewing", enumKey: .today),
        StatisticGroup(title: "Overall", enumKey: .overall),
        StatisticGroup(title: "Notes", enumKey: .notes),
        StatisticGroup(title: "Tasks", enumKey: .tasks),
        StatisticGroup(title: "Jobs", enumKey: .jobs),
    ]
    
    @State private var ref: UUID = UUID() // TODO: REMOVE THIS, JUST FOR TESTING

    @Environment(\.managedObjectContext) var moc
    
    @AppStorage("autoFixJobs") public var autoFixJobs: Bool = false
    
    private var notes: [Note] {
        LogRecords(moc: moc).notesForDate(selectedDate)
    }
    
    private var tasks: [LogTask] {
        var jobsForToday: [Int] = []
        
        for rec in records {
            if rec.job != nil {
                if !jobsForToday.contains(where: {$0 == Int(rec.job!.jid)}) {
                    jobsForToday.append(Int(String(format: "%1.f", rec.job!.jid)) ?? 0)
                }
            }
        }
        
        return CoreDataTasks(moc: moc).forDate(selectedDate, include: jobsForToday)
    }
    
    var body: some View {
        Section {
            Grid(alignment: .top, horizontalSpacing: 1, verticalSpacing: 1) {
                header
                    .font(Theme.font)
                
                ScrollView {
                    rows.font(Theme.font)
                }
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
            VStack(spacing: 1) {
                if statistics.count > 0 && records.count > 0 {
                    ForEach(LogTableDetails.groups) { group in
                        let children = statistics.filter({ $0.group == group.enumKey})
                        
                        if children.count > 0 {
                            if group.enumKey == .today {
                                DetailGroup(name: group.title, children: children, subTitle: DateHelper.dateFromRecord(records.first!))
                            } else {
                                DetailGroup(name: group.title, children: children)
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
    }
    
    private func update() -> Void {
        if records.count > 0 {
            statistics = []
            
            for record in records {
                if record.job != nil {
                    let colour = Color.fromStored(record.job?.colour ?? Theme.rowColourAsDouble)
                    
                    if !statistics.contains(where: {$0.value == "\(colour)"}) {
                        statistics.append(
                            Statistic(
                                key: record.job?.jid.string ?? "No ID",
                                value: "\(colour)",
                                colour: colour,
                                group: .jobs
                            )
                        )
                    }
                }
            }
            
            // Number of records in the set
            statistics.append(Statistic(key: "Records in set", value: String(records.count), colour: Theme.rowColour, group: .today))
            // Word count in the current set
            statistics.append(Statistic(key: "Word count", value: String(wordCount()), colour: Theme.rowColour, group: .overall))
            
            // Note list and count
            if notes.count > 0 {
                for note in notes {
                    statistics.append(
                        Statistic(
                            key: note.title!,
                            value: "",
                            colour: Theme.rowColour,
                            group: .notes,
                            linkAble: true,
                            linkTarget: note
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
                            colour: Color.fromStored(task.owner?.colour ?? Theme.rowColourAsDouble),
                            group: .tasks,
                            view: AnyView(TaskView(task: task, ref: $ref))
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
    
    static var previews: some View {
        LogTableDetails(records: $records, selectedDate: $selectedDate)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
