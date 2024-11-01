//
//  TaxonomyTermDefinitions.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-31.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

extension TaxonomyTermDefinitions {
    @ViewBuilder var rowView: some View {
        if let job = self.job {
            LogRow(
                entry: Entry(
                    timestamp: DateHelper.longDate(self.lastUpdate ?? Date()),
                    job: job,
                    message: "Term + Definition created: \(self.term?.name ?? "Error: Invalid term"): \(self.definition ?? "Error: Invalid definition content") at: \((self.lastUpdate ?? Date()).formatted()) "
                ),
                index: 0,
                colour: job.backgroundColor
            )
        }
    }
}
