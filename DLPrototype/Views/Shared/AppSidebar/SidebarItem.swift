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

public enum ItemType {
    case standard, thin

    var iconSize: (CGFloat, CGFloat) {
        switch self {
        case .standard:
            return (30, 30)
        case .thin:
            return (10, 10)
        }
    }

    var iconFrameSize: CGFloat {
        switch self {
        case .standard:
            return 50
        case .thin:
            return 20
        }
    }

    var frameHeight: CGFloat {
        switch self {
        case .standard:
            return 50
        case .thin:
            return 20
        }
    }

    var padding: CGFloat {
        switch self {
        case .standard:
            return 10
        case .thin:
            return 5
        }
    }
}

struct SidebarItem: View {
    public var data: String
    public var help: String
    public var icon: String?
    public var role: ItemRole = .standard
    public var type: ItemType = .standard

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
                        .frame(width: type.iconSize.0, height: type.iconSize.1)
                }
                .frame(width: type.iconFrameSize)
            }

            ZStack(alignment: .topLeading) {
                role.colour.opacity(0.02)
                Text(data)
                    .help(help)
                    .padding(type.padding)
            }
        }
        .border(.black.opacity(0.2), width: 1)
        .mask(
            RoundedRectangle(cornerRadius: 4)
        )
        .frame(maxHeight: type.frameHeight)
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
