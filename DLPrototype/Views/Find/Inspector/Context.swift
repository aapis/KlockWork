//
//  Context.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-29.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

extension FindDashboard.Inspector {
    public struct Context<T>: View {
        public var item: T
        // @TODO: refactor these vars into more structs (there will be dozens of these here once all entities are supported)
        private var recordReferences: Set<Date> = []
        private var planReferences: Set<Date> = []
        private var noteReferences: Set<Note> = []

        @Environment(\.managedObjectContext) var moc
        @EnvironmentObject private var nav: Navigation

        var body: some View {
            VStack(alignment: .leading) {
                FancyDivider()
                HStack(alignment: .top) {
                    FancySubTitle(text: "Context")
                    Spacer()
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        if recordReferences.count > 0 {
                            VStack(alignment: .leading) {
                                Divider()
                                HStack {
                                    Text("\(recordReferences.count) reference(s) in Records")
                                        .padding(5)
                                }
                                Divider()
                                ForEach(Array(recordReferences).sorted(by: {$0 >= $1}).prefix(10), id: \.self) { day in
                                    FancyButtonv2(
                                        text: day.formatted(date: .complete, time: .omitted),
                                        action: {actionOnClick(day)},
                                        icon: "arrow.right.square.fill",
                                        fgColour: .white,
                                        showIcon: true,
                                        size: .link
                                    )
                                    .help("Open day")
                                }
                            }
                        } else {
                            Divider()
                            HStack {
                                Text("No referenced Records")
                                    .padding(5)
                            }
                        }
                        
                        if planReferences.count > 0 {
                            VStack(alignment: .leading) {
                                Divider()
                                HStack {
                                    Text("\(planReferences.count) referenced Plan(s)")
                                        .padding(5)
                                }
                                Divider()
                                ForEach(Array(planReferences).sorted(by: {$0 >= $1}).prefix(10), id: \.self) { day in
                                    FancyButtonv2(
                                        text: day.formatted(date: .complete, time: .omitted),
                                        action: {actionShowPlan(day)},
                                        icon: "arrow.right.square.fill",
                                        fgColour: .white,
                                        showIcon: true,
                                        size: .link
                                    )
                                    .help("Show plan")
                                }
                            }
                        } else {
                            Divider()
                            HStack {
                                Text("No referenced Plans")
                                    .padding(5)
                            }
                        }
                        
                        if noteReferences.count > 0 {
                            VStack(alignment: .leading) {
                                Divider()
                                HStack {
                                    Text("\(noteReferences.count) referenced Note(s)")
                                        .padding(5)
                                }
                                Divider()
                                ForEach(Array(noteReferences).prefix(10), id: \.self) { note in
                                    FancyButtonv2(
                                        text: note.title ?? "No title",
                                        action: {actionShowNote(note)},
                                        icon: "arrow.right.square.fill",
                                        fgColour: .white,
                                        showIcon: true,
                                        size: .link
                                    )
                                    .help("Open note")
                                }
                            }
                        } else {
                            Divider()
                            HStack {
                                Text("No referenced Notes")
                                    .padding(5)
                            }
                        }
                    }
                }
            }
        }
        
        // @TODO: refactor this
        init(item: T) {
            self.item = item

            switch item {
            case is Job:
                let calendar = Calendar.autoupdatingCurrent
                let job = (item as! Job)

                // Find records associated with this job, list the days they were posted on
                if let records = job.records {
                    for record in records {
                        let tRecord = record as! LogRecord

                        if let timestamp = tRecord.timestamp {
                            let components = calendar.dateComponents([.day], from: timestamp)

                            if !recordReferences.contains(where: {
                                let co = calendar.dateComponents([.day], from: $0)
                                return co.day == components.day
                            }) {
                                recordReferences.insert(timestamp)
                            }
                        }
                    }
                }

                // Find plans that contain this item
                if let plans = job.plans {
                    for plan in plans {
                        let tPlan = plan as! Plan

                        if let date = tPlan.created {
                            let components = calendar.dateComponents([.day], from: date)

                            if !planReferences.contains(where: {
                                let co = calendar.dateComponents([.day], from: $0)
                                return co.day == components.day
                            }) {
                                planReferences.insert(date)
                            }
                        }
                    }
                }

                // Find associated notes
                if let notes = job.mNotes {
                    for note in notes {
                        noteReferences.insert(note as! Note)
                    }
                }
            default: print("DERPO failure")
            }
        }
    }
}

extension FindDashboard.Inspector.Context {
    private func actionOnClick(_ day: Date) -> Void {
        nav.session.date = day
        nav.session.search.cancel()
    }

    private func actionShowPlan(_ day: Date) -> Void {
        actionOnClick(day)
        nav.to(.planning)
    }

    private func actionShowNote(_ note: Note) -> Void {
        nav.session.search.cancel()
        nav.setView(AnyView(NoteCreate(note: note)))
        nav.setParent(.notes)
        nav.setSidebar(AnyView(NoteCreateSidebar(note: note)))
    }
}
