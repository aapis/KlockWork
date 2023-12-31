//
//  Templates.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-31.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct NoteTemplates {
    struct DefaultTemplate: Identifiable {
        let id: UUID = UUID()
        var template: String
        var name: String
    }
    
    public enum Template: CaseIterable {
        case label, sample, list, multilist

        var definition: DefaultTemplate {
            return switch self {
            case .label: DefaultTemplate(template: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque sit amet libero eu...\n\n", name: "Choose a template")
            case .sample: DefaultTemplate(template: "# Sample title\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque sit amet libero eu...\n\n", name: "Sample")
            case .list: DefaultTemplate(template: "# Incoming\n\n", name: "List")
            case .multilist: DefaultTemplate(template: "# Incoming\n\n", name: "Multi List")
            }
        }
        
        var id: Int {
            return switch self {
            case .label: 0
            case .sample: 1
            case .list: 2
            case .multilist: 3
            }
        }
    }
}
