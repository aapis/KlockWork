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
    @ObservedObject public var records: Records
    public var colours: [String: Color]
    
    private let font: Font = .system(.body, design: .monospaced)
    
    var body: some View {
        Section {
            Grid(alignment: .top, horizontalSpacing: 1, verticalSpacing: 1) {
                header
                    .font(font)
                
                ScrollView {
                    rows
                        .font(font)
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
                if records.statistics.count > 0 {
                    ForEach(records.groups) { group in
                        let children = records.statistics.filter({ $0.group == group.enumKey})
                        
                        if children.count > 0 {
                            DetailGroup(name: group.title, children: children)
                        }
                    }.onAppear(perform: {createColourMapFrom(records.colourMap)})
                } else {
                    LogRowEmpty(message: "No entries found for today", index: 0, colour: Theme.rowColour)
                }
            }
        }
    }
    
    private func createColourMapFrom(_ map: [String: Color]) -> Void {
        for row in map {
            if !records.statistics.contains(where: {$0.key == row.key}) {
                records.statistics.append(Statistic(key: row.key, value: "\(row.value)", colour: row.value, group: .colourReference))
            }
        }
    }
}

struct LogTableDetailsPreview: PreviewProvider {
    static var previews: some View {
        LogTableDetails(records: Records(), colours: ["11": Color.red])
    }
}
