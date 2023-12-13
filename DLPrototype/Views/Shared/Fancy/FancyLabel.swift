//
//  FancyLabel.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct FancyLabel: View {
    public var text: String = ""

    var body: some View {
        Text(text)
            .padding([.trailing], 10)
            .font(Theme.font)
            .frame(width: 120, height: 45, alignment: .trailing)
            .background(Theme.textLabelBackground)
    }
}
