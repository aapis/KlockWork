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
                ZStack {
                    LogTable.headerColour
                    Text("Job IDs")
                }
            }
        }
    }
    
    var rows: some View {
        VStack(spacing: 1) {
            if records.entries.count > 0 {
//                ForEach(records.jobIdsFor(Date())) { jid in
//                    Text("\(jid)")
//                }
            } else {
                LogRowEmpty(message: "No entries found for today", index: 0, colour: LogTable.rowColour)
            }
        }
    }
}

struct LogTableDetailsPreview: PreviewProvider {
    static var previews: some View {
        LogTableDetails(records: Records(), colours: ["11": Color.red])
    }
}
