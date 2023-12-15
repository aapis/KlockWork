//
//  FancyGenericToolbar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ToolbarButton {
    public var id: Int
    public var helpText: String
    public var label: AnyView?
    public var contents: AnyView?
}

struct FancyGenericToolbar: View {
    public var buttons: [ToolbarButton]
    public var standalone: Bool = false
    public var location: WidgetLocation = .content

    @State public var selectedTab: Int = 0
    
    var body: some View {
        VStack(spacing: location == .content ? 8 : 0) {
            GridRow {
                Group {
                    ZStack(alignment: .leading) {
                        (location == .sidebar ? .clear : Theme.toolbarColour)

                        HStack(spacing: 1) {
                            ForEach(buttons, id: \ToolbarButton.id) { button in
                                Button(action: {setActive(button.id)}) {
                                    ZStack(alignment: .leading) {
                                        (selectedTab == button.id ? (location == .sidebar ? Theme.base.opacity(0.2) : Theme.tabActiveColour) : Theme.tabColour)
                                        button.label
                                            .padding(location == .sidebar ? 0 : 16)
                                    }
                                }
                                .buttonStyle(.borderless)
                                .foregroundColor(Color.white)
                                .help(button.helpText)
                                .useDefaultHover({_ in})
                            }
                        }
                    }
                }
            }
            .frame(height: 35)

            GridRow {
                Group {
                    ZStack(alignment: .leading) {
                        if !standalone {
                            Theme.toolbarColour
                        }

                        VStack {
                            ForEach(buttons, id: \ToolbarButton.id) { button in
                                if button.id == selectedTab && button.contents != nil {
                                    button.contents
                                }
                            }
                        }
                        .padding(standalone ? 0 : 20)
                    }
                }
            }
        }
    }
}

extension FancyGenericToolbar {
    private func setActive(_ id: Int) -> Void {
        selectedTab = id
    }
}
