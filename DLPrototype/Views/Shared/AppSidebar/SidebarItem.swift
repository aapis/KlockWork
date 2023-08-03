//
//  SidebarItem.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-01.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

public enum ItemRole {
    case important, standard

    var colour: Color {
        switch self {
        case .important:
            return Color.red
        case .standard:
            return Color.black
        }
    }
}

struct SidebarItem: View {
    public var data: String
    public var help: String
    public var icon: String?
    public var role: ItemRole = .standard

    @State private var highlighted: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if let ic = icon {
                ZStack(alignment: .center) {
                    if role != .important {
                        role.colour.opacity(highlighted ? 0.15 : 0.08)
                    } else {
                        role.colour
                    }
                    Image(systemName: ic)
                        .font(.title2)
                        .frame(width: 30, height: 30)
                }
                .frame(width: 50)
            }

            ZStack(alignment: .topLeading) {
                role.colour.opacity(0.02)
                Text(data)
                    .help(help)
                    .padding()
            }
        }
        .border(.black.opacity(0.2), width: 1)
        .mask(
            RoundedRectangle(cornerRadius: 4)
        )
        .frame(maxHeight: 50)
        .onHover { inside in
            highlighted.toggle()
        }
        .contextMenu {
            Button("Copy \(data)") {
                ClipboardHelper.copy(data)
            }
        }
    }
}
