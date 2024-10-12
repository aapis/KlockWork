//
//  AssessmentFactor.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-11.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
import CoreData

extension AssessmentFactor {
    typealias EntityType = PageConfiguration.EntityType

    func factorDescription() -> String {
        if let type = self.getType() {
            if let action = self.getAction() {
                if self.count > 0 {
                    if action == .interaction {
                        return "\(self.count) \(type.enSingular) \(self.count > 1 ? action.enPlural : action.enSingular)"
                    } else {
                        return "\(self.count) \(self.count > 1 ? type.label : type.enSingular) \(self.count > 1 ? action.enPlural : action.enSingular)"
                    }
                } else {
                    return "\(type.enSingular) \(action.enSingular)"
                }
            }
        }

        return "_FACTOR_DESCRIPTION"
    }

    func countFactors(using moc: NSManagedObjectContext, for date: Date? = nil) -> Int64 {
        let selectedDate = date == nil ? self.date! : date!

        if let type = self.getType() {
            if let action = self.getAction() {
                switch type {
                case .records:
                    switch action {
                    case .create, .interaction:
                        return Int64(CoreDataRecords(moc: moc).countRecords(for: selectedDate))
                    }
                case .jobs:
                    switch action {
                    case .create:
                        return Int64(CoreDataJob(moc: moc).countByDate(for: selectedDate))
                    case .interaction:
                        return Int64(CoreDataRecords(moc: moc).countJobs(for: selectedDate))
                    }
                case .tasks:
                    switch action {
                    case .create:
                        return Int64(CoreDataTasks(moc: moc).countByDate(for: selectedDate))
                    case .interaction:
                        return Int64(CoreDataTasks(moc: moc).countByDate(for: selectedDate)) // @TODO: change query
                    }
                case .notes:
                    switch action {
                    case .create:
                        return Int64(CoreDataNotes(moc: moc).countByDate(for: selectedDate))
                    case .interaction:
                        return Int64(CoreDataNoteVersions(moc: moc).countByDate(for: selectedDate))
                    }
                    //            case .companies:
                    //            case .people:
                    //            case .projects:
                default:
                    return Int64(0)
                }
            }
        }

        return Int64(0)
    }

    /// Find the EntityType object for this instance
    /// - Returns: Optional(EntityType)
    fileprivate func getType() -> EntityType? {
        for entity in EntityType.allCases {
            if self.type == entity.label {
                return entity
            }
        }

        return nil
    }

    /// Find the ActionType object for this instance
    /// - Returns: Optional(ActionType)
    fileprivate func getAction() -> ActionType? {
        for entity in ActionType.allCases {
            if self.action == entity.label {
                return entity
            }
        }

        return nil
    }
}
