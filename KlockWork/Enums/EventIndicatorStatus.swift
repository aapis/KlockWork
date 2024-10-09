//
//  EventIndicatorStatus.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-01-02.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

enum EventIndicatorStatus {
    case upcoming, imminent, inProgress, ready

    var colour: Color {
        switch self {
        case .upcoming: .gray
        case .imminent: .orange
        case .inProgress: .green
        default: .clear
        }
    }
}
