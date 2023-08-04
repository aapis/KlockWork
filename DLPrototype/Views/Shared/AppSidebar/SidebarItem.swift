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

    var iconFrameSize: CGFloat {
        switch self {
        case .standard:
            return 50
        case .thin:
            return 30
        }
    }

    var frameHeight: CGFloat {
        switch self {
        case .standard:
            return 50
        case .thin:
            return 30
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

    var fontSize: Font {
        switch self {
        case .standard:
            return .body
        case .thin:
            return .caption
        }
    }
}

struct SidebarItem: View {
    public var data: String
    public var help: String
    public var icon: String?
    public var role: ItemRole = .standard
    public var type: ItemType = .standard
    public var action: (() -> Void)?

    @State private var highlighted: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if let ic = icon {
                ZStack(alignment: .topLeading) {
                    if role != .important {
                        role.colour.opacity(highlighted ? 0.15 : 0.08)
                    } else {
                        role.colour
                    }

                    Button(action: doAction) {
                        Image(systemName: ic)
                            .font(.title2)
                            .frame(maxWidth: 30, maxHeight: 30)
                    }
                    .buttonStyle(.plain)
//                    .useDefaultHover({_ in}) // TODO: this causes the cursor to stay off hover for some reason
                }
                .frame(width: type.iconFrameSize)
            }

            ZStack(alignment: .leading) {
                role.colour.opacity(0.02)
                Text(data)
                    .help(help)
                    .padding(type.padding)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .border(.black.opacity(0.2), width: 1)
        .mask(
            RoundedRectangle(cornerRadius: 4)
        )
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

extension SidebarItem {
    private func doAction() -> Void {
        if let callback = action {
            callback()
        }
    }
}
