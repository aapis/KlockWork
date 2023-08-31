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
    
    @State public var selectedTab: Int = 0
    
    var body: some View {
        VStack(spacing: 8) {
            GridRow {
                Group {
                    ZStack(alignment: .leading) {
                        Theme.toolbarColour

                        HStack(spacing: 1) {
                            ForEach(buttons, id: \ToolbarButton.id) { button in
                                Button(action: {setActive(button.id)}) {
                                    ZStack(alignment: .leading) {
                                        (selectedTab == button.id ? Theme.tabActiveColour : Theme.tabColour)
                                        button.label
                                            .padding()
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
