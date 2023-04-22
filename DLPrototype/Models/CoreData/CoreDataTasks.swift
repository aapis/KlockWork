//
//  CoreDataTasks.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-09.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

public class CoreDataTasks {
    public var moc: NSManagedObjectContext?
    
    public init(moc: NSManagedObjectContext?) {
        self.moc = moc
    }
    
    public func complete(_ task: LogTask) -> Void {
        task.completedDate = Date()
        task.lastUpdate = Date()
        
        do {
            try moc!.save()
        } catch {
            PersistenceController.shared.save()
        }
    }
    
    public func cancel(_ task: LogTask) -> Void {
        task.cancelledDate = Date()
        task.lastUpdate = Date()
        
        do {
            try moc!.save()
        } catch {
            PersistenceController.shared.save()
        }
    }
}
