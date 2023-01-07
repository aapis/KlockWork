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
    
    var body: some View {
        VStack {
            Button(action: action, label: {
                HStack {
                    Image(systemName: icon!)
                    Text(text)
                }
                .font(.title3)
                .padding()
                .onHover { inside in
                    if inside {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            })
            .buttonStyle(.borderless)
            .background(Theme.toolbarColour)
        }
    }
}

struct FancyButtonPreview: PreviewProvider {
    static var previews: some View {        
        FancyButton(text: "Button text", action: {}, icon: "checkmark.circle")
    }
}
