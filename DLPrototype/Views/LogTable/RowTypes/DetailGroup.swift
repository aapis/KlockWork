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
        VStack(spacing: 0) {
            HStack(spacing: 1) {
                ZStack(alignment: .leading) {
                    Theme.toolbarColour
                    
                    Text(name)
                        .padding(10)
                }
            }
            .frame(height: 52)
            
            Divider()
                .frame(height: 1)
                .background(Color.clear)
            
            if children.count > 0 {
                ForEach(children) { stat in
                    DetailsRow(key: stat.key, value: stat.value)
                }
            }
        }
    }
}

struct DetailGroupPreview: PreviewProvider {
    static var previews: some View {
        let statistics: [Statistic] = [
            Statistic(key: "Name", value: "Ryan Priebe", group: .today)
        ]
        
        DetailGroup(name: "Naughty List", children: statistics)
    }
}

