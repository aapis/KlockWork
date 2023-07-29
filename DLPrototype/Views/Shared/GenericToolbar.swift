//
//  GenericToolbar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-08.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct GenericToolbar: View {
    @Binding public var left: Int
    @Binding public var right: Int
    @Binding public var middle: Int
    
    @State private var leftPickerItems: [CustomPickerItem] = [
        CustomPickerItem(title: "Left", tag: 0)
    ]
    @State private var rightPickerItems: [CustomPickerItem] = [
        CustomPickerItem(title: "Right", tag: 0)
    ]
    
    var body: some View {
        GridRow {
            Group {
                HStack {
                    Title(text: "Multitasking", image: "square.split.2x1", showLabel: false)
                    FancyPicker(onChange: change, items: leftPickerItems, transparent: true, labelText: "Left")
                    FancyPicker(onChange: change, items: rightPickerItems, transparent: true, labelText: "Right")
                    Spacer()
                    FancyButton(text: "Number of columns", action: {}, icon: "square.split.3x1.fill", altIcon: "rectangle.split.2x1.fill", transparent: true, showLabel: false)
                }
                .padding()
                .background(Theme.toolbarColour)
                .onAppear(perform: setupPickers)
            }
        }
        .frame(height: 57)
    }
    
    private func setupPickers() -> Void {
//        leftPickerItems.append(contentsOf: Split.modules)
//        rightPickerItems.append(contentsOf: Split.modules)
    }
    
    private func change(selected: Int, sender: String?) -> Void {
        if sender == "Left" {
            left = selected
        } else {
            right = selected
        }
    }
}
