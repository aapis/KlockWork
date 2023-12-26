//
//  RecordTableColumn.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-29.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

public enum RecordTableColumn: CaseIterable {
    case index, timestamp, extendedTimestamp, job, message
    
    var width: CGFloat? {
        switch self {
        case .index: return 50
        case .timestamp, .extendedTimestamp: return 101
        case .job: return 80
        case .message: return nil
        }
    }
    
    var name: String {
        switch self {
        case .index: return ""
        case .timestamp, .extendedTimestamp: return "Timestamp"
        case .job: return "Job"
        case .message: return "Message"
        }
    }
    
    var alignment: Alignment {
        switch self {
        case .index: return .center
        case .timestamp, .extendedTimestamp: return .center
        case .job: return .center
        case .message: return .leading
        }
    }
}
