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
    
    var body: some View {
        GridRow {
            LogTextField(placeholder: "Search...", lineLimit: 1, onSubmit: {}, text: $text)
        }
    }
}
