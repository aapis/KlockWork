//
//  TaxonomyTerm.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2025-05-03.
//  Copyright © 2025 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension TaxonomyTerm {
    @ViewBuilder var rowView: some View {
        // @TODO: implement
//        if let date = self.created {
//            LogRow(
//                entry: Entry(
//                    timestamp: DateHelper.longDate(date),
//                    job: self,
//                    message: "Job created: \(self.title ?? self.jid.string)"
//                ),
//                index: 0,
//                colour: self.backgroundColor
//            )
//        } else if let date = self.lastUpdate {
//            LogRow(
//                entry: Entry(
//                    timestamp: DateHelper.longDate(date),
//                    job: self,
//                    message: "Job updated: \(self.title ?? self.jid.string)"
//                ),
//                index: 0,
//                colour: self.backgroundColor
//            )
//        }
    }

    @ViewBuilder var linkRowView: some View {
        HStack(alignment: .top) {
            Text(self.name ?? "Name")
            Spacer()
            Image(systemName: "chevron.right")
        }
        .foregroundStyle(.white)
        .padding(8)
        .background(Theme.textBackground)
        // @TODO: view cuts off and can't be read sometimes
//        .background(TypedListRowBackground(colour: self.backgroundColor, type: .jobs))
    }
}
