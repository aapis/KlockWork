//
//  Today.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-10.
//  Copyright © 2020 YegCollective. All rights reserved.
//
import SwiftUI
import KWCore

struct Today: View {
    @EnvironmentObject public var state: Navigation
    @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            if commandLineMode {
                CommandLineInterface()
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        PostingInterface()
                        LogTable()
                    }
                    .padding()
                    UI.AppFooter(
                        start: self.state.session.date.startOfDay,
                        end: self.state.session.date.endOfDay
                    )
                }
            }
        }
        .background(self.PageBackground)
    }

    @ViewBuilder private var PageBackground: some View {
        ZStack {
            if [.classic].contains(self.state.theme.style) {
                Theme.base
                Theme.toolbarColour
            }
        }
    }
}
