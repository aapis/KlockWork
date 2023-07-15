//
//  FancyPicker.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-07.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct FancyPicker: View {
    public var onChange: (Int, String?) -> Void
    public var items: [CustomPickerItem] = []
    public var transparent: Bool? = false
    public var labelText: String?
    public var showLabel: Bool? = false
    public var defaultSelected: Int = 0
    
    @State private var selection: Int = 0
    
    var body: some View {
        Group {
            if showLabel! {
                showWithLabel
            } else {
                showNoLabel
            }
        }
        .onAppear(perform: {
            selection = defaultSelected
        })
    }
    
    var showNoLabel: some View {
        VStack {
            Picker(labelText ?? "Picker", selection: $selection) {
                ForEach(items) { item in
                    Text(item.title)
                        .tag(item.tag)
                        .disabled(item.disabled)
                        .font(Theme.font)
                }
            }
            .background(transparent! ? Color.clear : Theme.toolbarColour)
            .onHover { inside in
                if inside {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
            .labelsHidden()
            .frame(width: 200)
            .font(Theme.font)
            .onChange(of: selection) { _ in
                onChange(selection, labelText)
            }
        }
    }
    
    var showWithLabel: some View {
        VStack {
            Picker(labelText ?? "Picker", selection: $selection) {
                ForEach(items) { item in
                    Text(item.title)
                        .tag(item.tag)
                        .disabled(item.disabled)
                        .font(Theme.font)
                }
            }
            .background(transparent! ? Color.clear : Theme.toolbarColour)
            .onHover { inside in
                if inside {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
            .frame(width: 200)
            .font(Theme.font)
            .onChange(of: selection) { _ in
                onChange(selection, labelText)
            }
        }
    }
}

struct FancyPickerPreview: PreviewProvider {
    static var previews: some View {
        FancyPicker(onChange: change, items: [])
    }
    
    static private func change(num: Int, sender: String?) -> Void {
        
    }
}
