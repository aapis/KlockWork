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
            
            if key != nil {
                if key == k {
                    ids[k] = UUID()
                }
            } else {
                ids[k] = UUID()
            }
        }
    }
    
    public func set(_ uuids: [String: UUID]) -> Void {
        ids = uuids
    }
}
