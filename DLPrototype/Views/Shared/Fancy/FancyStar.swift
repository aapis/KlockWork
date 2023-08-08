//
//  FancyStar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-07.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct FancyStar: View {
    public var background: Color = Color.clear

    var body: some View {
        Image(systemName: "star.fill")
            .foregroundColor(background.isBright() ? .black : .yellow)
            .shadow(color: (background.isBright() ? Color.yellow : Color.black).opacity(0.4), radius: 3)
    }
}
