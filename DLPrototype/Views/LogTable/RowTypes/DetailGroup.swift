//
//  DetailGroup.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-03.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct DetailGroup: View {
    public var name: String
    public var children: [Statistic]
    
    var body: some View {
        HStack(spacing: 1) {
            ZStack(alignment: .leading) {
                LogTable.toolbarColour
                
                Text(name)
                    .padding(10)
            }
        }
        
        if children.count > 0 {
            ForEach(children) { stat in
                DetailsRow(key: stat.key, value: stat.value)
            }
        }
    }
}
