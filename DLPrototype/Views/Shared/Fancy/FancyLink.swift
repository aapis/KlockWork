//
//  FancyLink.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct FancyLink: View {
    public var icon: String
    public var label: String? = ""
    public var showLabel: Bool = false
    public var destination: AnyView?
    
    var body: some View {
        VStack {
            NavigationLink {
                destination
            } label: {
                Image(systemName: icon)
                
                if showLabel && label != nil {
                    Text(label!)
                }
            }
            .buttonStyle(.borderless)
            .foregroundColor(Color.white)
            .font(.title3)
            .padding()
            .background(Color.black.opacity(0.2))
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
