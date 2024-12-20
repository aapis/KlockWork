//
//  Plan.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-29.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension Plan {
    func isEmpty() -> Bool {
        return tasks!.count + jobs!.count + notes!.count == 0
    }

    @ViewBuilder var rowView: some View {
        HStack {
            Image(systemName: "hexagon")
            Text("Plan found")
            Spacer()
            Text(DateHelper.todayShort(self.created ?? Date(), format: "MMMM dd, yyyy"))
                .foregroundStyle(.gray)
        }
        .padding(8)
        .background(.gray)
        .foregroundStyle(.white)
    }
}
