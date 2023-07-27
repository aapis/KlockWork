//
//  SidebarButton.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-27.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct SidebarButton: View, Identifiable {
    public var id: UUID = UUID()
    @Binding public var view: AnyView

    public var destination: AnyView
    @Binding public var currentPage: Page
    public let pageType: Page
    public var icon: String
    public var label: String
    public var showLabel: Bool = true

    @State private var highlighted: Bool = false

    var body: some View {
        Button(action: {
            view = destination
            currentPage = pageType
        }, label: {
            ZStack {
                currentPage == pageType ? Color.pink : Theme.headerColour
                LinearGradient(
                    colors: [(highlighted ? .black : .white), Theme.toolbarColour],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
                .opacity(0.1)

                Image(systemName: icon)
                    .font(.largeTitle)
                    .symbolRenderingMode(.hierarchical)
            }
        })
        .help(label)
        .frame(width: 50, height: 50)
        .buttonStyle(.plain)
        .onHover { inside in
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }

            highlighted.toggle()
        }
    }
}
