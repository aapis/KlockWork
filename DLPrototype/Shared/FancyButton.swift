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
    public var transparent: Bool? = false
    public var showLabel: Bool? = true
    
    var body: some View {
        VStack {
            Button(action: action, label: {
                HStack {
                    Image(systemName: icon!)
                    if showLabel! {
                        Text(text)
                    }
                }
                .foregroundColor(Color.white)
                .font(.title3)
                .padding()
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
            .background(transparent! ? Color.clear : Theme.toolbarColour)
        }
    }
}

struct FancyButtonPreview: PreviewProvider {
    static var previews: some View {        
        FancyButton(text: "Button text", action: {}, icon: "checkmark.circle")
    }
}
