//
//  FancyHelpText.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-25.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct FancyHelpText: View {
    public var text: String = "Some help text"
    var body: some View {
        Text(text)
            .foregroundColor(.gray)
            .font(.caption)
    }
}
