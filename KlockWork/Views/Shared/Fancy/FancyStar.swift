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
            .shadow(color: (background.isBright() ? Color.yellow : Color.black).opacity(0.4), radius: 3)
    }
}


struct FancyStarv2: View {
    var body: some View {
        Image(systemName: "star.fill")
            .padding(.trailing, 8)
            .foregroundStyle(.yellow)
            .font(.title3)
            .shadow(color: .black.opacity(0.5), radius: 3)
    }
}
