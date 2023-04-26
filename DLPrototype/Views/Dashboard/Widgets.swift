//
//  Widgets.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct Widgets: View {
    @EnvironmentObject public var crm: CoreDataRecords
    @EnvironmentObject public var updater: ViewUpdater
    @EnvironmentObject public var jm: CoreDataJob
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Title(text: "Welcome back!", image: "house")
                    Spacer()
                }
                
                FancyDivider()
                
                Grid(alignment: .top, horizontalSpacing: 5, verticalSpacing: 5) {
                    GridRow {
                        ThisDay().environmentObject(crm)
                        ThisWeek().environmentObject(crm)
                        ThisMonth().environmentObject(crm)
                    }
                    .frame(maxHeight: 250)
                    
                    GridRow(alignment: .top) {
                        ThisYear().environmentObject(crm)
                        Favourites()
                    }
                    .frame(maxHeight: 250)
                }
            }
            .font(Theme.font)
            .padding()
        }
        .background(Theme.toolbarColour)
    }
}
