//
//  Templates.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-31.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct NoteTemplates {
    var templates: [Template] = []

    struct Template: Identifiable, Equatable {
        let id: UUID = UUID()
        var name: String
        var template: String?
        var file: String?
        
        init(name: String, file: String, template: String? = "") {
            self.name = name
            self.file = file

            if !file.isEmpty {
                do {
                    if let path = Bundle.main.url(forResource: file, withExtension: "md") {
                        self.template = try String(contentsOf: path)
                    }
                } catch {
                    print("[error] Template load error")
                }
            } else {
                if let tmpl = template {
                    self.template = tmpl
                }
            }
        }
    }
    
    public enum DefaultTemplateConfiguration: CaseIterable {
        case meeting, list, empty

        var definition: Template {
            return switch self {
            case .meeting: Template(name: "Meeting", file: "Meeting")
            case .list: Template(name: "List", file: "List")
            case .empty: Template(name: "Empty", file: "", template: "")
            }
        }
        
        var id: Int {
            return switch self {
            case .meeting: 1
            case .list: 2
            case .empty: 3
            }
        }
    }
}
