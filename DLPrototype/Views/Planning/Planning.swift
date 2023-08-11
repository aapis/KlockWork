//
//  Planning.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-10.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct Planning: View {
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        Title(text: "Planning")
        FancySubTitle(text: "What am I working on today?")

        WorkingOnToday

        FancySubTitle(text: "Daily Summary")
    }

    private var WorkingOnToday: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                JobPickerWidget(location: .content)
                    .frame(width: 320)
                VStack(alignment: .leading) {
                    ForEach(Array(nav.session.planning.jobs)) { job in
                        Text(job.jid.string)
                    }
                }
            }
        }
        .padding()
    }
}
