//
//  ActionType.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-11.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

public enum ActionType: CaseIterable {
    case create, interaction

    // @TODO: localize, somehow?
    var label: String {
        switch self {
        case .create: "Create"
        case .interaction: "Interaction"
        }
    }

    // @TODO: localize, somehow?
    var enPlural: String {
        switch self {
        case .create: "created"
        case .interaction: "interactions"
        }
    }

    // @TODO: localize, somehow?
    var enSingular: String {
        switch self {
        case .create: "created"
        case .interaction: "interaction"
        }
    }

    // @TODO: localize, somehow?
    var enModifyLabel: String {
        switch self {
        case .create: "creation"
        case .interaction: "interaction"
        }
    }
}
