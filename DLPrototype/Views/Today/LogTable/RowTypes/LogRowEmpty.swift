//
//  LogRowEmpty.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct LogRowEmpty: View, Identifiable {
    public let id = UUID()
    public var message: String
    public var index: Array<Entry>.Index?
    public var colour: Color
    
    var body: some View {
        HStack(spacing: 1) {
            GridRow {
                Group {
                    ZStack {
                        tigerStripe()
                        Text(message)
                            .padding(10)
                    }
                }
            }
        }
    }
    
    private func tigerStripe() -> Color {
        return colour.opacity(index!.isMultiple(of: 2) ? 1 : 0.5)
    }
}

struct LogTableRowEmptyPreview: PreviewProvider {
    @State static public var sj: String = "11.0"
    
    static var previews: some View {
        VStack {
            LogRowEmpty(message: "Nothing to see here", index: 0, colour: Theme.rowColour)
            LogRow(entry: Entry(timestamp: "2023-01-01 19:49", job: "11", message: "Hello, world"), index: 1, colour: Theme.rowColour, selectedJob: $sj)
        }
    }
}
