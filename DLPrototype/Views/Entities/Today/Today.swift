//
//  Add.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-10.
//  Copyright © 2020 YegCollective. All rights reserved.
//
import SwiftUI

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
                VStack(alignment: .leading) {
                    PostingInterface()
                    LogTable()
                }
                .padding()
            }
        }
        .background(Theme.toolbarColour)
    }
}
