//
//  ViewModeSelector.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-16.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

public struct ViewModeSelector: View {
    @EnvironmentObject public var nav: Navigation
    
    @AppStorage("today.viewMode") public var index: Int = 0
    
    private var items: [CustomPickerItem] {
        return [
            CustomPickerItem(title: "View mode", tag: 0),
            CustomPickerItem(title: "Full", tag: 1),
            CustomPickerItem(title: "Plain", tag: 2)
        ]
    }
    
    public var body: some View {
        FancyPicker(onChange: change, items: items, defaultSelected: index)
            .onAppear(perform: {self.change(selected: index, sender: "")})
            .onChange(of: self.index) {
                change(selected: self.index, sender: "")
            }
    }
    
    private func change(selected: Int, sender: String?) -> Void {
        if selected == 1 || selected == 0 {
            self.nav.session.toolbar.mode = .full
        } else if selected == 2 {
            self.nav.session.toolbar.mode = .plain
        }
        
        index = selected
    }
}
