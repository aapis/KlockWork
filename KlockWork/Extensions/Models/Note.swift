//
//  Note.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-31.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

extension Note {
    @ViewBuilder var rowView: some View {
        if let date = self.postedDate {
            LogRow(
                entry: Entry(
                    timestamp: DateHelper.longDate(date),
                    job: self.mJob!,
                    message: "Note created: \(self.title ?? "Error: Invalid note title")"
                ),
                index: 0,
                colour: self.mJob?.backgroundColor ?? Theme.rowColour
            )
        }
    }
}
