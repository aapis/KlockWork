//
//  FancyPickerWithRelativeNavigation.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-08.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

// TODO: do I need this anymore?
struct FancyPickerWithRelativeNavigation: View {
    public var onChange: (Int) -> Void
    public var items: [CustomPickerItem] = []
    public var transparent: Bool? = false
    public var labelText: String?
    public var showLabel: Bool? = false
    
    @Binding public var sd: Date
    
    @State private var selection: Int = 0
    
    var body: some View {
        HStack(spacing: 0) {
            FancyButton(text: "Previous day", action: previous, icon: "chevron.left", transparent: true, showLabel: false)
                .frame(maxHeight: 20)
            FancyPicker(onChange: onChange, items: items, transparent: transparent, labelText: labelText, showLabel: showLabel)
            FancyButton(text: "Next day", action: next, icon: "chevron.right", transparent: true, showLabel: false)
                .frame(maxHeight: 20)
        }
    }
    
    private func previous() -> Void {
        selection += 1
        print("Fancy::prev.selection \(selection)")
        let item = items[selection].title
        sd = DateHelper.date(item) ?? Date()
    }
    
    private func next() -> Void {
        
        selection -= 1
        print("Fancy::next.selection \(selection)")
        
        let item = items[selection].title
        sd = DateHelper.date(item) ?? Date()
    }
    
//    private func change(selected: Int) -> Void {
//        selection = selected
//
//        onChange(selection)
//
//
//        // change the picker's selected value
////        let item = items[selection].title
//
//
//        print("Fancy::change.selection \(selection)")
//    }
}

//struct FancyPickerWithRelativeNavigationPreview: PreviewProvider {
//    @State private var sd: Date?
//    static var previews: some View {
//        FancyPickerWithRelativeNavigation(onChange: change, items: [], sd: $sd)
//    }
//
//    static private func change(num: Int) -> Void {
//
//    }
//}
