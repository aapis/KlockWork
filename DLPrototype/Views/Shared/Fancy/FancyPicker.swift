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
    public var size: PickerSize = .small
    
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
                        // @TODO: this doesn't actually work; see https://stackoverflow.com/a/76154257
                        .disabled(item.disabled)
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
            .frame(width: size == .small ? 200 : nil)
            .padding([.trailing], size == .small ? 0 : 16)
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
                        // @TODO: this doesn't actually work; see https://stackoverflow.com/a/76154257
                        .disabled(item.disabled)
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
            .frame(width: size == .small ? 200 : nil)
            .padding([.trailing], size == .small ? 0 : 16)
            .font(Theme.font)
            .onChange(of: selection) { _ in
                onChange(selection, labelText)
            }
        }
    }
}
