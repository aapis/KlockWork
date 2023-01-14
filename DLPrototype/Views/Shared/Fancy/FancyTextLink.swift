//
//  FancyTextLink.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct FancyTextLink: View {
    public var text: String
    public var transparent: Bool? = true
    public var showIcon: Bool? = false
    public var destination: AnyView?
    
    var body: some View {
        VStack {
            NavigationLink {
                destination
            } label: {
                if showIcon! {
                    Image(systemName: "link")
                }
                
                Text(text)
                    .font(Theme.font)
            }
            .buttonStyle(.borderless)
            .foregroundColor(Color.white)
            .font(.title3)
            .padding()
            .background(transparent! ? Color.clear : Color.black.opacity(0.2))
            .onHover { inside in
                if inside {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }
}
