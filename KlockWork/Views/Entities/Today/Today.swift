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
    public var defaultSelectedDate: Date? = nil
    private let page: PageConfiguration.AppPage = .today

    @AppStorage("today.commandLineMode") private var commandLineMode: Bool = false

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading) {
            if commandLineMode {
                CommandLineInterface()
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    PostingInterface()
                    LogTable()
                }
                .padding()
            }
        }
        .background(Theme.toolbarColour)
    }
}
