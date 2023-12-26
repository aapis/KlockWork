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
        self.icon = AnyView(Image(systemName: icon).font(.title2))
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
                    if mode == .full {
                        Full(buttons: buttons, location: location, selected: $selected)
                    } else {
                        Compact(buttons: buttons, location: location, selected: $selected)
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

    struct Compact: View {
        public var buttons: [ToolbarButton]
        public var location: WidgetLocation
        @Binding public var selected: Int
        
        @EnvironmentObject public var nav: Navigation

        var body: some View {
            ZStack(alignment: .leading) {
                (location == .sidebar ? .clear : Theme.toolbarColour)
                
                HStack(spacing: 1) {
                    ForEach(buttons, id: \ToolbarButton.id) { button in
                        Button(action: {setActive(button)}) {
                            ZStack(alignment: .center) {
                                (selected == button.id ? (location == .sidebar ? Theme.base.opacity(0.2) : Theme.tabActiveColour) : Theme.tabColour)
                                
                                if selected != button.id && location == .content {
                                    VStack {
                                        Spacer()
                                        UIGradient()
                                    }
                                }
                                
                                button.icon
                                    .padding(location == .sidebar ? 0 : 16)
                            }
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(Color.white)
                        .help(button.helpText)
                        .frame(width: 70)
                        .useDefaultHover({_ in})
                    }
                }
            }
        }
    }
    
    struct Full: View {
        public var buttons: [ToolbarButton]
        public var location: WidgetLocation
        @Binding public var selected: Int
        
        @EnvironmentObject public var nav: Navigation

        var body: some View {
            ZStack(alignment: .leading) {
                (location == .sidebar ? .clear : Theme.toolbarColour)
                
                HStack(spacing: 1) {
                    ForEach(buttons, id: \ToolbarButton.id) { button in
                        Button(action: {setActive(button)}) {
                            ZStack(alignment: .leading) {
                                (selected == button.id ? (location == .sidebar ? Theme.base.opacity(0.2) : Theme.tabActiveColour) : Theme.tabColour)
                                
                                if selected != button.id && location == .content {
                                    VStack {
                                        Spacer()
                                        UIGradient()
                                    }
                                }
                                
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
    
    struct UIGradient: View {
        var body: some View {
            LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom)
                .opacity(0.6)
                .blendMode(.softLight)
                .frame(height: 12)
        }
    }
}

extension FancyGenericToolbar.Full {
    private func setActive(_ button: ToolbarButton) -> Void {
        selected = button.id
    }
}

extension FancyGenericToolbar.Compact {
    private func setActive(_ button: ToolbarButton) -> Void {
        selected = button.id
    }
}
