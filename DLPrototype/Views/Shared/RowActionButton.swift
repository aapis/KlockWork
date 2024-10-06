//
//  RowActionButton.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-05.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct RowActionButton: View {
    @EnvironmentObject public var state: Navigation
    public var callback: (() -> Void)
    public var icon: String?
    public var iconAsImage: Image?
    public var helpText: String = ""
    public var highlightedColour: Color = .yellow
    public var page: PageConfiguration.AppPage = .explore
    @State private var isHighlighted: Bool = false

    var body: some View {
        Button {
            self.callback()
        } label: {
            ZStack(alignment: .center) {
                LinearGradient(colors: [Theme.base, .clear], startPoint: .leading, endPoint: .trailing)
                self.isHighlighted ? self.highlightedColour : self.state.session.appPage.primaryColour

                if let icon = self.icon {
                    Image(systemName: icon)
                        .symbolRenderingMode(.hierarchical)
                        .padding(5)
                } else if let iconAsImage = self.iconAsImage {
                    iconAsImage
                        .symbolRenderingMode(.hierarchical)
                        .padding(5)
                }
            }
            .foregroundStyle(self.isHighlighted ? Theme.base : self.highlightedColour)
        }
        .font(.headline)
        .buttonStyle(.plain)
        .help(self.helpText)
        .useDefaultHover({ hover in self.isHighlighted = hover })
    }
}
