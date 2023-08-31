//
//  ViewUpdater.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation

public class ViewUpdater: ObservableObject {
    // TODO: this is gross, try to remove it
    @Published public var ids: [String: UUID] = [
        "today.table": UUID(),
        "today.picker": UUID(),
        "today.dayList": UUID(),
        "today.calendarStrip": UUID(),
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
        "sidebar.today.incompleteTasksWidget": UUID(),
        "sidebar.widget.dateSelector": UUID(),
        "task.dashboard": UUID(),
        "note.dashboard": UUID(),
        "project.dashboard": UUID(),
        "project.view": UUID(),
        "job.dashboard": UUID(),
        "dashboard.header": UUID(),
        "sidebar": UUID(),
        "planning.daily": UUID(),
    ]

    public func get(_ key: String) -> UUID {
        ids[key]!
    }
    
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

    public func setOne(_ key: String, _ uuid: UUID) -> Void {
        ids[key] = uuid
    }
}
