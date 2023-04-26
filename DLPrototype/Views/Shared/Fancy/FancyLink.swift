//
//  FancyLink.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public enum ButtonSize {
    case small, medium, large
}

struct FancyLink: View {
    public var icon: String
    public var showIcon: Bool = true
    public var label: String? = ""
    public var showLabel: Bool = false
    public var colour: Color = Color.clear
    public var fgColour: Color = Color.white
    public var destination: AnyView?
    public var size: ButtonSize = .large
    
    @State private var padding: CGFloat = 10
    
    var body: some View {
        VStack {
            NavigationLink {
                destination
            } label: {
                if showIcon {
                    Image(systemName: icon)
                }
                
                if showLabel && label != nil {
                    Text(label!)
                        .foregroundColor(fgColour)
                        .font(Theme.font)
                }
            }
            .buttonStyle(.borderless)
            .foregroundColor(Color.white)
            .font(.title3)
            .padding(padding)
            .background(colour)
            .onHover { inside in
                if inside {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
        .onAppear(perform: onAppear)
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
