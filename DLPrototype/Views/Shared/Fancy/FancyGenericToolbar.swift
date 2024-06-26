//
//  FancyGenericToolbar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ToolbarButton: Hashable, Equatable {
    static func == (lhs: ToolbarButton, rhs: ToolbarButton) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var id: Int
    public var helpText: String
    public var icon: AnyView?
    public var label: AnyView?
    public var labelText: String?
    public var contents: AnyView?
    
    init(id: Int, helpText: String, label: AnyView?, contents: AnyView?) {
        self.id = id
        self.helpText = helpText
        self.label = label
        self.contents = contents
    }
    
    init(id: Int, helpText: String, icon: String, labelText: String, contents: AnyView?) {
        self.id = id
        self.helpText = helpText
        self.icon = AnyView(Image(systemName: icon))
        self.label = AnyView(
            HStack {
                self.icon
                Text(labelText)
            }
        )
        self.labelText = labelText
        self.contents = contents
    }
}

enum ToolbarMode {
    case full, compact
}

struct FancyGenericToolbar: View {
    public var buttons: [ToolbarButton]
    public var standalone: Bool = false
    public var location: WidgetLocation = .content
    public var mode: ToolbarMode = .full

    @EnvironmentObject public var nav: Navigation
    
    @State public var selected: Int = 0

    var body: some View {
        VStack(spacing: location == .content ? 8 : 0) {
            GridRow {
                Group {
                    ZStack(alignment: .topLeading) {
                        (location == .sidebar ? .clear : Theme.toolbarColour)

                        HStack(spacing: 1) {
                            ForEach(buttons, id: \ToolbarButton.id) { button in
                                TabView(
                                    button: button,
                                    location: location,
                                    selected: $selected,
                                    mode: mode
                                )
                                
                                if buttons.count == 1 {
                                    Text(buttons.first!.helpText)
                                        .padding(.leading, 10)
                                }
                            }
                        }
                    }
                }
            }
            .frame(height: 32)

            GridRow {
                Group {
                    ZStack(alignment: .leading) {
                        if !standalone {
                            Theme.toolbarColour
                        }
                        
                        VStack {
                            ForEach(buttons, id: \ToolbarButton.id) { button in
                                if button.id == selected && button.contents != nil {
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

    struct TabView: View {
        public var button: ToolbarButton
        public var location: WidgetLocation
        @Binding public var selected: Int
        public var mode: ToolbarMode

        @State private var highlighted: Bool = false
        
        var body: some View {
            if location == .sidebar {
                if mode == .compact {
                    ButtonView.frame(width: 40)
                } else {
                    ButtonView
                }
            } else {
                if mode == .compact {
                    ButtonView.frame(width: 60)
                } else {
                    ButtonView
                }
            }
        }

        var ButtonView: some View {
            Button(action: {setActive(button)}) {
                ZStack(alignment: mode == .compact ? .center : .leading) {
                    (
                        selected == button.id ?
                        (
                            location == .sidebar ? Theme.base.opacity(0.2) : Theme.tabActiveColour
                        )
                        :
                        (
                            highlighted ? Theme.base.opacity(0.2) : Theme.tabColour
                        )
                    )

                    if selected != button.id && location == .content {
                        VStack {
                            Spacer()
                            UIGradient()
                        }
                    }
                    
                    if location == .sidebar {
                        if mode == .compact {
                            button.icon.padding(0)
                        } else {
                            button.label.padding(0)
                        }
                    } else {
                        if mode == .compact {
                            button.icon.padding(16)
                        } else {
                            button.label.padding(16)
                        }
                    }
                }
            }
            .buttonStyle(.borderless)
            .foregroundColor(Color.white)
            .help(button.helpText)
            .useDefaultHover({ hover in highlighted = hover})
        }
    }

    struct UIGradient: View {
        var body: some View {
            LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom)
                .opacity(0.6)
                .blendMode(.softLight)
                .frame(height: 12)
        }
    }
}

extension FancyGenericToolbar.TabView {
    private func setActive(_ button: ToolbarButton) -> Void {
        selected = button.id
    }
}
