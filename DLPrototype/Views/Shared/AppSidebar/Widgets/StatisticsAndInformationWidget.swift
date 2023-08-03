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

    public init(date: Binding<Date>) {
        _date = date
        _notes = CoreDataNotes.fetchRecentNotes(limit: 7)
        _records = CoreDataRecords.fetchForDate(date.wrappedValue)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FancySubTitle(text: "\(title)")
                Spacer()
                FancyButtonv2(
                    text: "Minimize",
                    action: {minimized.toggle()},
                    icon: minimized ? "plus" : "minus",
                    showLabel: false,
                    type: .white
                )
                .frame(width: 30, height: 30)
            }

            if !minimized {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("Viewing")
                        Spacer()
                        Text(DateHelper.dateFromRecord(records.first!))
                    }
                    HStack {
                        Text("Records in set")
                        Spacer()
                        Text(records.count.description)
                    }
                    HStack {
                        Text("View description")
                        Spacer()
                        Text("Coming soon...")
                    }
                    HStack {
                        Text("Word count")
                        Spacer()
                        Text("Coming soon...")
                    }
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
