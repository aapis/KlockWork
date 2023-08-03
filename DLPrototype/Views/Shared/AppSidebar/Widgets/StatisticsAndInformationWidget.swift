//
//  StatisticsAndInformationWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct StatisticsAndInformationWidget: View {
    public let title: String = "Statistics & Information"

    @State private var minimized: Bool = false
    
    @Binding public var date: Date

    @FetchRequest public var notes: FetchedResults<Note>
    @FetchRequest public var records: FetchedResults<LogRecord>

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FancySubTitle(text: "\(title)")
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
                    SidebarItem(data: dateForToday(), help: "Viewing")
                    SidebarItem(data: "Coming soon", help: "View description")
                    SidebarItem(data: "Coming soon", help: "Word count")
                    SidebarItem(data: records.count.description + " records", help: "Records in set")
                }
            }
        }
    }
}

//struct SidebarWidget: View {
//
//}
//
//extension SidebarWidget: View {
//    // TODO: put parts of the view into this extension and extend all sidebar with this struct
//}

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
}
