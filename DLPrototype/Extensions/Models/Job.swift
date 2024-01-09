//
//  Job.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

extension Job {
    typealias Field = Navigation.Forms.Field

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
    
    /// Create form fields for the important properties and relationships
    /// - Returns: [Field]
    func fields() -> [Field] {
        var fields: [Field] = []

        fields.append(Field(type: .text, label: "Job ID", value: self.jid.string, entity: self, keyPath: "jid"))
        fields.append(Field(type: .text, label: "Title", value: self.title, entity: self, keyPath: "title"))
        fields.append(Field(type: .boolean, label: "Published", value: self.alive, entity: self, keyPath: "alive"))
        fields.append(Field(type: .boolean, label: "SRED Qualified", value: self.shredable, entity: self, keyPath: "shredable"))
        // @TODO: make this a sidebar calendar selector
        fields.append(Field(type: .text, label: "Last update", value: self.lastUpdate?.formatted(date: .abbreviated, time: .omitted), entity: self, keyPath: "lastUpdate"))
        // @TODO: make this a sidebar calendar selector
        fields.append(Field(type: .text, label: "Created", value: self.created?.formatted(date: .abbreviated, time: .omitted), entity: self, keyPath: "created"))
        fields.append(Field(type: .colour, label: "Colour", value: self.colour, entity: self, keyPath: "colour"))
        fields.append(Field(type: .editor, label: "Description", value: self.overview, entity: self, keyPath: "overview"))

        return fields
    }
}
