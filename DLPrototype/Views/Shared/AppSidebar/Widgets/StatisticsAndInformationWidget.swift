//
//  StatisticsAndInformationWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct StatisticsAndInformationWidget: View {
    public let title: String = "Information"

    @State private var minimized: Bool = false

    @Binding public var date: Date

    @FetchRequest public var notes: FetchedResults<Note>
    @FetchRequest public var records: FetchedResults<LogRecord>

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FancySubTitle(text: title)
                Spacer()
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
                VStack(alignment: .leading, spacing: 5) {
                    SidebarItem(data: calculateWordCount(), help: "Word count")
                    SidebarItem(data: recordCount(), help: "Records in set")
                    FancyDivider()
                }
            }
        }
    }
}

extension StatisticsAndInformationWidget {
    public init(date: Binding<Date>) {
        _date = date
        _notes = CoreDataNotes.fetchRecentNotes(limit: 7)
        _records = CoreDataRecords.fetchForDate(date.wrappedValue)
    }

    private func dateForToday() -> String {
        var out = "Date: "

        if let rec = records.first {
            out += DateHelper.dateFromRecord(rec)
        } else {
            out += DateHelper.todayShort(date)
        }

        return out
    }

    private func actionMinimize() -> Void {
        withAnimation {
            minimized.toggle()
        }
    }

    private func calculateWordCount() -> String {
        let count = CoreDataRecords(moc: moc).countWordsIn(
            // converts records to an array, I assume this is terrible but it works
            records.map {$0}
        )

        if count == 1 {
            return "\(count) word"
        }

        return "\(count) words"
    }

    private func recordCount() -> String {
        if records.count == 1 {
            return records.count.description + " record"
        }

        return records.count.description + " records"
    }
}
