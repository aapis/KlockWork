//
//  LegendLabel.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-11.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct LegendLabel: View {
    public let label: String
    public let icon: String? = nil

    var body: some View {
        HStack(spacing: 5) {
            if icon != nil {
                Image(systemName: icon!)
            }

            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            Spacer()
        }
    }
}
