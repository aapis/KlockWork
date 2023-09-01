//
//  Summary.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-09-01.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

extension Planning {
    struct Summary: View {
        @EnvironmentObject public var nav: Navigation

        @FetchRequest public var records: FetchedResults<LogRecord>

        var body: some View {
            VStack {
                HStack {
                    Text("Summary")
                    Spacer()
                }

                Text("Off topic")
            }
            .padding()
            .background(Theme.headerColour)
        }
    }
}

extension Planning.Summary {
    init() {
        _records = CoreDataRecords.fetchForDate(Date())
    }
}
