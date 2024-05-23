//
//  Job.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

extension Job {
#if os(macOS)
    typealias Field = Navigation.Forms.Field
    
    /// Field definitions used to generate user-editable forms for this object
    var fields: [Field] {
        [
            Field(type: .text, label: "Job ID", value: self.jid.string, entity: self, keyPath: "jid"),
            Field(type: .text, label: "Title", value: self.title, entity: self, keyPath: "title"),
            Field(type: .text, label: "URL", value: self.uri, entity: self, keyPath: "uri"),
            Field(type: .colour, label: "Colour", value: self.colour, entity: self, keyPath: "colour"),
            Field(type: .boolean, label: "Published", value: self.alive, entity: self, keyPath: "alive"),
            Field(type: .boolean, label: "SRED Qualified", value: self.shredable, entity: self, keyPath: "shredable"),
            Field(type: .date, label: "Last update", value: self.lastUpdate?.formatted(date: .abbreviated, time: .standard), entity:self, keyPath: "lastUpdate"),
            Field(type: .date, label: "Created", value: self.created?.formatted(date: .abbreviated, time: .standard), entity: self,keyPath: "created"),
            Field(type: .projectDropdown, label: "Project", value: self.project, entity: self, keyPath: "project"),
            Field(type: .editor, label: "Description", value: self.overview, entity: self, keyPath: "overview")
        ]
    }
#endif

    var idInt: Int { Int(exactly: jid.rounded(.toNearestOrEven)) ?? 0 }

    var backgroundColor: Color {
        if let c = colour {
            return Color.fromStored(c)
        }

        return Color.clear
    }

    var foregroundColor: Color { self.backgroundColor.isBright() ? .black : .white }

//    public static let attributes : [KeyPath<Job, Any>] = [
//        \.name!, \.created!
//    ]

    // @TODO: the following are dupes and should be deprecated then removed
    func id_int() -> Int {
        return Int(exactly: jid.rounded(.toNearestOrEven)) ?? 0
    }

    // @TODO: this seems to return a much lighter shade of the actual colour, fix that
    func colour_from_stored() -> Color {
        if let c = colour {
            return Color.fromStored(c)
        }

        return Color.clear
    }

    func fgColour() -> Color {
        return self.colour_from_stored().isBright() ? .black : .white
    }
}
