//
//  ViewUpdater.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation

public class ViewUpdater: ObservableObject {
    @Published public var ids: [String: UUID] = [
        "today.table": UUID(),
        "today.picker": UUID(),
        "today.dayList": UUID(),
        "ltd.rows": UUID(),
        "dg.hasView": UUID(),
        "dg.hasNoView": UUID(),
        "tlv.table": UUID(),
        "pv.form": UUID(),
        "pc.form": UUID(),
        "find.rr": UUID(),
        "find.nr": UUID(),
        "find.tr": UUID(),
        "find.pr": UUID(),
        "find.jr": UUID(),
    ]
    
    public func update(_ key: String? = "") -> Void {
        for (k, _) in ids {
            ids[k] = UUID()
        }
    }
    
    public func updateOne(_ key: String = "") -> Void {
        ids[key] = UUID()
    }
    
    public func set(_ uuids: [String: UUID]) -> Void {
        ids = uuids
    }
}
