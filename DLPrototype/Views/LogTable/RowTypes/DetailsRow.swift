//
//  DetailsRow.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-03.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct DetailsRow: View {
    public var key: String
    public var value: String
//    public var group: StatisticGroup
    
//    @AppStorage("tigerStriped") private var tigerStriped = false
    
    var body: some View {
        HStack(spacing: 1) {
            ZStack(alignment: .leading) {
                LogTable.rowColour
                
                Text(key)
                    .padding(10)
            }
            
            ZStack(alignment: .leading) {
                LogTable.rowColour
                
                Text(value)
                    .padding(10)
            }
        }
    }
}
