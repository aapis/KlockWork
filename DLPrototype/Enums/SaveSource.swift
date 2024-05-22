//
//  SaveSource.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

public enum SaveSource {
    case auto, manual
    
    var name: String {
        return switch self {
        case .auto: "Automatic"
        case .manual: ""
        }
    }
}
