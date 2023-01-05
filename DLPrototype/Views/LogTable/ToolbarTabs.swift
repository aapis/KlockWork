//
//  Toolbar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ToolbarTabs: View {
    @Binding public var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 1) {
            // TODO: convert these button/styles to custom button views and styles
            Button(action: {setActive(0)}, label: {
                ZStack {
                    (selectedTab == 0 ? Theme.tabActiveColour : Theme.tabColour)
                    Image(systemName: "tray.2.fill")
                }
            })
            .buttonStyle(.borderless)
            .foregroundColor(Color.white)
            .help("View all of today's records")
            .frame(width: 50)
            
            Button(action: {setActive(1)}, label: {
                ZStack {
                    (selectedTab == 1 ? Theme.tabActiveColour : Theme.tabColour)
                    Image(systemName: "square.grid.3x1.fill.below.line.grid.1x2")
                }
            })
            .buttonStyle(.borderless)
            .foregroundColor(Color.white)
            .help("Today's records grouped by JOB ID")
            .frame(width: 50)
            
            Button(action: {setActive(2)}, label: {
                ZStack {
                    (selectedTab == 2 ? Theme.tabActiveColour : Theme.tabColour)
                    Image(systemName: "magnifyingglass")
                }
            })
            .buttonStyle(.borderless)
            .foregroundColor(Color.white)
            .help("Search today's records")
            .frame(width: 50)
        }
    }
    
    private func setActive(_ index: Int) -> Void {
        selectedTab = index
    }
}
