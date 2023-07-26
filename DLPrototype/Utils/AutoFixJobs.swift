//
//  AutoFixJobs.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

final public class AutoFixJobs {
    static public func run(records: [LogRecord], context: NSManagedObjectContext) -> Void {
        let defaultJob = CoreDataJob(moc: context).byId(11.0)
        for rec in records {
            if rec.job == nil {
                rec.job = defaultJob
                
                PersistenceController.shared.save()
            }
        }
    }
}
