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
    public var subTitle: String?
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(spacing: 1) {
                    Text(name).padding(10)
                    
                    Spacer()
                    if subTitle != nil {
                        Text(subTitle!).padding(10)
                    }
                }
                .background(Theme.toolbarColour)
            }
            
            Divider()
                .frame(height: 1)
                .background(Color.clear)
            
            if children.count > 0 {
                ForEach(children) { stat in
                    DetailsRow(key: stat.key, value: stat.value, colour: stat.colour)
                }
            }
        }
    }
}

struct DetailGroupPreview: PreviewProvider {
    static var previews: some View {
        let statistics: [Statistic] = [
            Statistic(key: "Name", value: "Ryan Priebe", colour: Theme.rowColour, group: .today)
        ]
        
        VStack {
            DetailGroup(name: "Naughty List", children: statistics, subTitle: DateHelper.todayShort())
            DetailGroup(name: "Good List", children: statistics)
        }
    }
}
