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
        private var references: Set<Date> = []

        @Environment(\.managedObjectContext) var moc
        @EnvironmentObject private var nav: Navigation

        var body: some View {
            VStack(alignment: .leading) {
                FancyDivider()
                HStack(alignment: .top) {
                    FancySubTitle(text: "Context")
                    Spacer()
                }
                
                if references.count > 0 {
                    VStack(alignment: .leading) {
                        Divider()
                        HStack {
                            Text("\(references.count) reference(s) in Records")
                                .padding(5)
                        }
                        Divider()
                        ForEach(Array(references).sorted(by: {$0 >= $1}).prefix(10), id: \.self) { day in
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
                        Divider()
                    }
                } else {
                    HStack {
                        Text("No references in Records")
                            .padding(5)
                    }
                }
            }
        }
        
        init(item: T) {
            self.item = item

            switch item {
            case is Job:
                let job = (item as! Job)
                if let records = job.records {
                    for record in records {
                        let tRecord = record as! LogRecord

                        if let timestamp = tRecord.timestamp {
                            let calendar = Calendar.autoupdatingCurrent
                            let components = calendar.dateComponents([.day], from: timestamp)

                            if !references.contains(where: {
                                let co = calendar.dateComponents([.day], from: $0)
                                return co.day == components.day
                            }) {
                                references.insert(timestamp)
                            }
                        }
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
}
