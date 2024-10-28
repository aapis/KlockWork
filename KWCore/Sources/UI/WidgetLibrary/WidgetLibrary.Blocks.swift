//
//  WidgetLibrary.Blocks.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-28.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension WidgetLibrary.UI {
    public struct Blocks {
        struct Definition: View {
            @EnvironmentObject public var state: Navigation
            public var definition: TaxonomyTermDefinitions
            @State private var isHighlighted: Bool = false

            var body: some View {
                Button {
                    self.state.session.job = self.definition.job
                    self.state.session.project = self.state.session.job?.project
                    self.state.session.company = self.state.session.project?.company
                    self.state.session.definition = self.definition
                    self.state.to(.definitionDetail)
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Text(self.definition.definition ?? "Error: Missing definition")
                        Spacer()
                    }
                    .padding(8)
                    .background(self.definition.job?.backgroundColor ?? Theme.rowColour)
                    .foregroundStyle((self.definition.job?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base : Theme.lightWhite)
                }
                .buttonStyle(.plain)
                .useDefaultHover({ hover in self.isHighlighted = hover})
            }
        }
    }
}
