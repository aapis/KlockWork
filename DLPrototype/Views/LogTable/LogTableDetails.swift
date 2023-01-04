//
//  LogTableDetails.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

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
                    LogTable.headerColour
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
                    ForEach(records.statistics) { stat in
                        DetailsRow(key: stat.key, value: stat.value)
                    }
                } else {
                    LogRowEmpty(message: "No entries found for today", index: 0, colour: LogTable.rowColour)
                }
            }
        }
    }
}

struct LogTableDetailsPreview: PreviewProvider {
    static var previews: some View {
        LogTableDetails(records: Records(), colours: ["11": Color.red])
    }
}
