//
//  FancyDropdown.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-05-16.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct FancyDropdown: View {
    public var label: String
    public var icon: String = "chevron.up.chevron.down"
    public var items: [Any] = []
    public var onChange: () -> Void = {}
    
    @State private var showChildren: Bool = false
    
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        Button {
            print("[debug]")
        } label: {
            HStack(spacing: 5) {
                Text(label)
                Image(systemName: icon)
            }
            .padding(10)
            .background(.white.opacity(0.15))
            .mask(Capsule())
        }
        .buttonStyle(.plain)
        .useDefaultHover({_ in})
    }
}

#Preview {
    FancyDropdown(label: "Type")
}
