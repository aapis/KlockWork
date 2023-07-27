//
//  SidebarButton.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-27.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct SidebarButton: View {
    @Binding public var view: AnyView

    public var destination: AnyView
    public var icon: String
    public var label: String
    public var showLabel: Bool = false

    @State private var active: Bool = false

    var body: some View {
        Button(action: {
            view = destination

//            print("DERPO view \(type(of: view))") // result: AnyView
//            print("DERPO dest \(type(of: destination))") // result: AnyView

            if type(of: view) != type(of: destination) {
                active = true
            }
        }, label: {
            ZStack {
                Theme.headerColour
                LinearGradient(colors: [Color.white, Theme.toolbarColour], startPoint: .topTrailing, endPoint: .bottomLeading)
                    .opacity(0.1)
//                (active ? Color.red : Theme.toolbarColour)
                if showLabel {
                    Text(label)
                }

                Image(systemName: icon)
                    .font(.largeTitle)
                    .symbolRenderingMode(.hierarchical)
            }
        })
        .help(label)
        .frame(width: 50, height: 50)
        .buttonStyle(.plain)
//        .border(width: 1, edges: [.top, .leading, .bottom], color: .white)
        .onHover { inside in
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}
