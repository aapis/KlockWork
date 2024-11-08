//
//  TypedListRowBackground.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-05.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct TypedListRowBackground: View {
    public let colour: Color
    public let type: PageConfiguration.EntityType

    var body: some View {
        ZStack(alignment: .topTrailing) {
            self.colour
            LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                .opacity(0.1)
            type.icon
                .font(.system(size: 70))
                .foregroundStyle(self.colour.isBright() ? self.colour : .black.opacity(0.2))
                .opacity(0.3)
                .shadow(color: self.colour.isBright() ? .black.opacity(0.2) : .white.opacity(0.2), radius: 4, x: 1, y: 1)
        }
    }
}
