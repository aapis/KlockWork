//
//  FancyButton.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-07.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct FancyButton: View {
    public var text: String
    public var action: () -> Void
    public var icon: String? = "checkmark.circle"
    public var altIcon: String? = "checkmark.circle"
    public var transparent: Bool? = false
    public var showLabel: Bool? = true
    public var showIcon: Bool? = true
    public var fgColour: Color?
    public var size: ButtonSize = .large
    
    @State private var padding: CGFloat = 10
    
    var body: some View {
        VStack {
            Button(action: action, label: {
                HStack {
                    if showIcon! {
                        Image(systemName: icon!)
                            .foregroundColor(fgColour != nil ? fgColour : .white)
                    }
                    
                    if showLabel! {
                        Text(text)
                    }
                }
                .foregroundColor(Color.white)
                .font(.title3)
                .padding(padding)
                .help(text)
                .onHover { inside in
                    if inside {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            })
            .buttonStyle(.borderless)
            .background(transparent! ? Color.clear : Color.black.opacity(0.2))
            .onAppear(perform: onAppear)
        }
    }
    
    private func onAppear() -> Void {
        switch size {
        case .small:
            padding = 0
        case .medium:
            padding = 5
        case .large:
            padding = 10
        }
    }
}

struct FancyButtonPreview: PreviewProvider {
    static var previews: some View {        
        FancyButton(text: "Button text", action: {}, icon: "checkmark.circle")
    }
}
