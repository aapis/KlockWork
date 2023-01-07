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
    public var onChange: (Int) -> Void
    public var items: [CustomPickerItem] = []
    public var transparent: Bool? = false
    public var labelText: String?
    public var showLabel: Bool? = false
    
    @State private var selection: Int = 0
    
    var body: some View {
        VStack {
            Picker(labelText ?? "Picker", selection: $selection) {
                ForEach(items) { item in
                    Text(item.title)
                        .tag(item.tag)
                        .disabled(item.disabled)
                        .font(Theme.font)
                }
            }
            .background(Theme.toolbarColour)
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
                onChange(selection)
            }
        }
    }
}

struct FancyPickerPreview: PreviewProvider {
    static var previews: some View {
        FancyPicker(onChange: change, items: [])
    }
    
    static private func change(num: Int) -> Void {
        
    }
}
