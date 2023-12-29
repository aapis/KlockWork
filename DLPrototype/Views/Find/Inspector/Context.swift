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
        private var days: [IdentifiableDay] = []
        
        @Environment(\.managedObjectContext) var moc

        var body: some View {
            VStack(alignment: .leading) {
                FancyDivider()
                HStack(alignment: .top) {
                    FancySubTitle(text: "Context")
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    Divider()
                    Text("\(days.count) Days containing entries")
                    
                    ForEach(days) { day in
                        Text(day.string)
                    }
                }
            }
        }
        
        init(item: T) {
            self.item = item
            var days: [IdentifiableDay] = []
            
            switch item {
            case is Job:
                if let records = (item as! Job).records {
//                    let sequence = Array(records)
//                    let groupedRecords = Dictionary(grouping: sequence, by: {($0 as! LogRecord).job!})
                    for record in records {
                        let tRecord = record as! LogRecord
                        //                    print("DERPO record=\(tRecord)")
                        
                        if let timestamp = tRecord.timestamp {
                            days.append(
                                IdentifiableDay(
                                    string: timestamp.formatted(),
                                    date: timestamp,
                                    recordCount: 0
                                )
                            )
                        }
                    }
                }
            default: print("DERPO failure")
            }
            
            print("DERPO days.count=\(days.count)")
        }
    }
}
