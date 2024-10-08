//
//  WidgetLibrary.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-07.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct WidgetLibrary {
    struct ResetUserChoicesButton: View {
        @EnvironmentObject public var state: Navigation
        public var onActionClear: (() -> Void)?

        var body: some View {
            FancyButtonv2(
                text: "Reset interface to default state",
                action: self.onActionClear != nil ? self.onActionClear : self.defaultClearAction,
                icon: "arrow.clockwise.square",
                iconWhenHighlighted: "arrow.clockwise.square.fill",
                fgColour: self.state.session.job?.backgroundColor.isBright() ?? false ? Theme.base : .white,
                showLabel: false,
                size: .small,
                type: .clear,
                font: .title
            )
            .help("Reset interface to default state")
            .frame(width: 25)
            .disabled(self.state.session.job == nil)
            .opacity(self.state.session.job == nil ? 0.5 : 1)
        }
    }
}

extension WidgetLibrary.ResetUserChoicesButton {
    private func defaultClearAction() -> Void {
        self.state.session.job = nil
        self.state.session.project = nil
        self.state.session.company = nil
    }
}
