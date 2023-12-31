//
//  Templates.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-31.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct NoteTemplates {
    var templates: [Template] = []

    struct Template: Identifiable, Equatable {
        let id: UUID = UUID()
        var template: String
        var name: String
    }
    
    public enum DefaultTemplateConfiguration: CaseIterable {
        case sample, list, multilist, empty

        var definition: Template {
            return switch self {
            case .sample: Template(template: "# Sample title\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque sit amet libero eu...\n\n", name: "Sample")
            case .list: Template(template: "# Incoming\n\n", name: "List")
            case .multilist: Template(template: "# Incoming\n\n", name: "Multi List")
            case .empty: Template(template: "", name: "Empty")
            }
        }
        
        var id: Int {
            return switch self {
            case .sample: 1
            case .list: 2
            case .multilist: 3
            case .empty: 4
            }
        }
    }
}

extension NoteTemplates {
    func load(path: String) -> Void {
        
    }
}
