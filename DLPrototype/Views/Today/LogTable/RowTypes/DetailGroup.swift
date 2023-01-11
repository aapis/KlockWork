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
    public var children: [any Statistics]
    public var subTitle: String?
    
    @State private var showChildren: Bool = true
    @State private var minimizeIcon: String = "arrowtriangle.up"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                HStack(spacing: 1) {
                    Text(name).padding(10)

                    Spacer()
                    
                    if subTitle != nil {
                        Text(subTitle!).padding(10)
                    } else {
                        FancyButton(text: "Minimize", action: minimize, icon: minimizeIcon, transparent: true, showLabel: false)
                            .padding(10)
                    }
                }
                .background(Theme.toolbarColour)
            }
            
            Divider()
                .frame(height: 1)
                .background(Color.clear)
            
            if children.count > 0 && showChildren {
                ForEach(children, id: \Statistics.id) { stat in
                    if stat.view != nil {
                        stat.view
                            .background(stat.colour)
                            .foregroundColor(stat.colour.isBright() ? Color.black : Color.white)
                    } else {
                        DetailsRow(key: stat.key, value: stat.value, colour: stat.colour)
                    }
                }
            }
        }
    }
    
    private func minimize() -> Void {
        withAnimation(.easeInOut) {
            showChildren.toggle()
        }
        
        if showChildren {
            minimizeIcon = "arrowtriangle.up"
        } else {
            minimizeIcon = "arrowtriangle.down"
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
