//
//  LogTableDetails.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

// TODO: this whole view should be based on a given day (param?), not on "today" (for Search)
struct LogTableDetails: View {
    public var colours: [String: Color]
    public var today: FetchedResults<LogRecord>
    
    @State private var statistics: [Statistic] = []
    
    public var groups: [StatisticGroup] = [ // TODO: I tried to pull these from the enum but it was so FUCKING FRUSTRATING that I almost yeeted the codebase into the sun
        StatisticGroup(title: "Today", enumKey: .today),
        StatisticGroup(title: "Yesterday", enumKey: .yesterday),
        StatisticGroup(title: "Overall", enumKey: .overall),
        StatisticGroup(title: "Colour Reference", enumKey: .colourReference),
    ]
    
    @Environment(\.managedObjectContext) var moc
    
    private let font: Font = .system(.body, design: .monospaced)
    
    var body: some View {
        Section {
            Grid(alignment: .top, horizontalSpacing: 1, verticalSpacing: 1) {
                header
                    .font(font)
                
                ScrollView {
                    rows.font(font)
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
                if statistics.count > 0 && today.count > 0 {
                    ForEach(groups) { group in
                        let children = statistics.filter({ $0.group == group.enumKey})
                        
                        if children.count > 0 {
                            if group.enumKey == .today {
                                DetailGroup(name: group.title, children: children, subTitle: DateHelper.dateFromRecord(today.first!))
                            } else {
                                DetailGroup(name: group.title, children: children)
                            }
                        }
                    }
                } else {
                    LogRowEmpty(message: "Stats are loading", index: 0, colour: Theme.rowColour)
                }
            }
        }.onAppear(perform: update)
    }
    
    private func update() -> Void {
//        let items: [LogRecord] = LogRecords(moc: moc).fromToday()!
        
        for record in today {
            if record.job != nil {
                let colour = Color.fromStored(record.job?.colour ?? Theme.rowColourAsDouble)
                
                if !statistics.contains(where: {$0.value == "\(colour)"}) {
                    statistics.append(Statistic(key: record.job?.jid.string ?? "No ID", value: "\(colour)", colour: colour, group: .colourReference))
                }
            }
        }
        
        // Number of records in the set
        statistics.append(Statistic(key: "# Records", value: String(today.count), colour: Theme.rowColour, group: .today))
        // Number of records overall
        // Word count in the current set
        statistics.append(Statistic(key: "Word count", value: String(wordCount()), colour: Theme.rowColour, group: .overall))
    }
    
    private func wordCount() -> Int {
        var words: [String] = []
        
        for item in today {
            words.append(item.message!)
        }
        
        let wordSet: Set = Set(words.joined(separator: " ").split(separator: " "))
        
        return wordSet.count
    }
}

//struct LogTableDetailsPreview: PreviewProvider {
//    static var previews: some View {
//        LogTableDetails(colours: ["11": Color.red])
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
