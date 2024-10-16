//
//  FancyHelpText.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-25.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct FancyHelpText: View {
    public var text: String = "Some help text"
    public var icon: String? = "questionmark.app.fill"
    public var page: PageConfiguration.AppPage = .error
    @State private var highlighted: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            if let icon = self.icon {
                Image(systemName: icon)
                    .symbolRenderingMode(.hierarchical)
            }
            Text(text)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(8)
        .foregroundColor(.gray)
        .font(.callout)
        .background(self.page.primaryColour.opacity(0.5))
        .clipShape(.rect(bottomLeadingRadius: 5, bottomTrailingRadius: 5))
    }
}
