//
//  FancyStar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-07.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct FancyStar: View {
    public var background: Color = Color.clear

    var body: some View {
        Image(systemName: "star.fill")
            .foregroundColor(background.isBright() ? .black : .yellow)
            .shadow(color: (background.isBright() ? Color.yellow : Theme.base).opacity(0.4), radius: 3)
    }
}


struct FancyStarv2: View {
    var body: some View {
        Image(systemName: "star.fill")
            .padding(.trailing, 8)
            .foregroundStyle(.yellow)
            .shadow(color: Theme.base, radius: 1, x: 1, y: 1)
    }
}
