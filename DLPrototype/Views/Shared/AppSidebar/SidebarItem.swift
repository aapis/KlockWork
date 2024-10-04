//
//  SidebarItem.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-01.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

public enum ItemRole {
    case important, standard, action

    var colour: Color {
        switch self {
        case .important:
            return Color.red
        case .standard:
            return Color.black
        case .action:
            return Color.green
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

public enum ItemOrientation {
    case left, right
}

struct SidebarItem: View, Identifiable {
    public let id: UUID = UUID()
    public var data: String
    public var help: String
    public var icon: String?
    @State public var altIcon: String?
    public var orientation: ItemOrientation = .left
    public var role: ItemRole = .standard
    public var type: ItemType = .standard
    public var action: (() -> Void)?
    public var showBorder: Bool = true
    public var showButton: Bool = true

    @AppStorage("CreateEntitiesWidget.isSearchStackShowing") private var isSearching: Bool = false

    @State private var highlighted: Bool = false

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            if orientation == .left {
                HStack(alignment: .top, spacing: 0) {
                    if showButton {
                        ItemIcon
                        ItemLabel
                    } else {
                        RowButton
                    }
                }
            } else {
                HStack(alignment: .top, spacing: 0) {
                    if showButton {
                        ItemLabel
                        ItemIcon
                    } else {
                        RowButton
                    }
                }
            }
        }
        .border(.black.opacity(0.2), width: (showBorder ? 1 : 0))
        .onAppear(perform: actionOnAppear)
        .contextMenu {
            Button("Copy \(data)") {
                ClipboardHelper.copy(data)
            }
            Divider()
            Button(action: {
                isSearching = true
                nav.session.search.text = data
            }, label: {
                Text("Inspect")
            })
        }
    }

    @ViewBuilder private var ItemIcon: some View {
        if let ic = icon {
            Button(action: doAction) {
                ZStack(alignment: .center) {
                    if ![.important, .action].contains(role) {
                        role.colour.opacity(highlighted ? 0.15 : 0.08)
                    } else {
                        role.colour
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                        if let alt = altIcon {
                            if highlighted {
                                Image(systemName: alt)
                            } else {
                                Image(systemName: ic)

                            }
                        } else {
                            Image(systemName: ic)
                        }
                        Spacer()
                    }
                    .font(.title2)
                }
                .frame(width: type.iconFrameSize)
            }
            .buttonStyle(.plain)
            .useDefaultHover({ inside in highlighted = inside})
        }
    }

    @ViewBuilder private var RowButton: some View {
        if let ic = icon {
            Button(action: doAction) {
                ZStack(alignment: .center) {
                    if ![.important, .action].contains(role) {
                        role.colour.opacity(highlighted ? 0.15 : 0.08)
                    } else {
                        role.colour
                    }
                    HStack(alignment: .center) {
                        HStack(alignment: .center, spacing: 0) {
                            Text(data)
                                .help(help)
                                .padding(type.padding)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .background([.important, .action].contains(role) ? role.colour.opacity(0.02) : .clear)

                        ZStack(alignment: .trailing) {
                            ZStack(alignment: .center) {
                                Theme.base.opacity(0.6).blendMode(.softLight)
                                if let alt = altIcon {
                                    if highlighted {
                                        Image(systemName: alt)
                                            .foregroundStyle(Theme.base.opacity(0.5))
                                    } else {
                                        Image(systemName: ic)
                                            .foregroundStyle(Theme.base.opacity(0.5))
                                    }
                                } else {
                                    Image(systemName: ic)
                                        .foregroundStyle(Theme.base.opacity(0.5))
                                }
                            }
                            .frame(width: 30, height: 30)
                            .cornerRadius(5)
//                            .padding(.trailing, type.padding)
                        }
                        .padding(8)
                    }
                }
                .useDefaultHover({ inside in highlighted = inside})
            }
            .buttonStyle(.plain)
        }
    }

    private var ItemLabel: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(data)
                .help(help)
                .padding(type.padding)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .background([.important, .action].contains(role) ? role.colour.opacity(0.02) : .clear)
    }
}

extension SidebarItem {
    private func doAction() -> Void {
        if let callback = action {
            callback()
        }
    }

    private func actionOnAppear() -> Void {
        if self.showButton {
            if let ic = icon {
                altIcon = ic + ".fill"
            }
        }
    }
}
