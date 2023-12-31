//
//  Templates.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-31.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

//struct Templates {
//    static var sample: Dictionary<String, String> = ["Sample": "# Sample title\n\nSome text here."]
//}

public enum Template: CaseIterable {
    case sample, list, multilist
}

struct NoteTemplates: Identifiable {
    let id: UUID = UUID()
    var selected: Template
    var templates: [Any] = [
        Sample(),
        List(),
        MultiList()
    ]
    
    var body: some View {
        Text("HI")
    }

    struct Sample {
        let id: UUID = UUID()
        var template: String = "# Sample title\n\nSome text here."
        var name: String = "Sample"
    }
    
    struct List {
        let id: UUID = UUID()
        var template: String = "# Incoming"
        var name: String = "List"
    }
    
    struct MultiList {
        let id: UUID = UUID()
        var template: String = "# Incoming"
        var name: String = "Multi List"
    }
}
