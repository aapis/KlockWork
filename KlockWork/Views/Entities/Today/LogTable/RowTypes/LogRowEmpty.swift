//
//  LogRowEmpty.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

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
                            .foregroundColor(.gray)
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
