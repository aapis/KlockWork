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
        "tlv.table": UUID()
    ]
    
    public func update() -> Void {
        for (k, _) in ids {
            ids[k] = UUID()
        }
    }
    
    public func set(_ uuids: [String: UUID]) -> Void {
        ids = uuids
    }
}