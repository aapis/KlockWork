//
//  FancyTab.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-05-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct FancyTab: View {
    @State public var tab: Tab
    
    @Binding public var selected: Int
    
    var body: some View {
        Button(action: {setActive(tab.id)}, label: {
            ZStack {
                (selected == tab.id ? Theme.tabActiveColour : Theme.tabColour)
                Image(systemName: tab.icon)
            }
        })
        .buttonStyle(.borderless)
        .foregroundColor(Color.white)
        .help(tab.help)
        .frame(width: 50)
        .onHover { inside in
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
    
    private func setActive(_ index: Int) -> Void {
        selected = index
    }
}
