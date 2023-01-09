//
//  SearchBar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct SearchBar: View {
    @Binding public var text: String
    public var disabled: Bool
    
    var body: some View {
        GridRow {
            HStack {
                ZStack(alignment: .trailing) {
                    FancyTextField(placeholder: "Search...", lineLimit: 1, onSubmit: {}, disabled: disabled, text: $text)
                    
                    Spacer()
                    
                    if text.count > 0 {
                        FancyButton(text: "Reset", action: reset, icon: "xmark", showLabel: false)
                            .padding()
                    }
                }
            }
        }
    }
    
    private func reset() -> Void {
        text = ""
    }
}
