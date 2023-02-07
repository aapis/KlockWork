//
//  Column.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-03.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct Column: View {
    public var colour: Color
    public var textColour: Color
    public var index: Array<Entry>.Index?
    
    @Binding public var text: String
    
    @AppStorage("tigerStriped") private var tigerStriped = false
    
    var body: some View {
        Group {
            ZStack(alignment: .center) {
                colour
                
                Text(text)
                    .padding(10)
                    .foregroundColor(textColour)
                    .help(text)
            }
        }
    }
}
