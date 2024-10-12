//
//  Assessables.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-11.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
import CoreData

class Assessables: Identifiable, Equatable {
    typealias EntityType = PageConfiguration.EntityType

    var id: UUID = UUID()
    var factors: [AssessmentFactor] = []
    var moc: NSManagedObjectContext?
    var score: Int = 0
    var weight: ActivityWeight = .empty
    var date: Date? = nil
    var statuses: [AssessmentThreshold] = []

    /// Stub for Equatable compliance
    /// - Parameters:
    ///   - lhs: Assessables
    ///   - rhs: Assessables
    /// - Returns: Bool
    static public func == (lhs: Assessables, rhs: Assessables) -> Bool {
        return lhs.id == rhs.id
    }
    
    /// Create a new Assessables object
    /// - Parameters:
    ///   - factors: Optional(Array<AssessmentFactor>)
    ///   - moc: Optional(NSManagedObjectContext)
    init(factors: [AssessmentFactor]? = nil, statuses: [AssessmentThreshold]? = nil, moc: NSManagedObjectContext? = nil) {
        self.id = UUID()

        if moc != nil {
            self.moc = moc!
        }

        if factors != nil {
            self.factors = factors!
        }

        if let stats = statuses {
            self.statuses = stats
        }

        self.evaluate()
    }

    /// Shortcut for self.factors.isEmpty
    /// - Returns: Bool
    func isEmpty() -> Bool {
        return factors.isEmpty
    }
    
    /// Filters assessment factors by the given type
    /// - Parameter type: EntityType
    /// - Returns: Array<AssessmentFactor>
    func byType(_ type: EntityType) -> [AssessmentFactor] {
        return self.sorted().filter({$0.type == type.label})
    }
    
    /// Sort by count
    /// - Returns: Array<AssessmentFactor>
    func sorted() -> [AssessmentFactor] {
        return self.factors.sorted(by: {$0.count > $1.count})
    }
    
    /// Filter out factors that we don't want to consider because they fall below the user's threshold
    /// - Returns: Array<AssessmentFactor>
    func active() -> [AssessmentFactor] {
        return self.sorted().filter({$0.count >= $0.threshold})
    }
    
    /// Find all unused factors
    /// - Returns: Array<AssessmentFactor>
    func inactive() -> [AssessmentFactor] {
        return self.sorted().filter({$0.count <= $0.threshold})
    }
    
    /// Destroy all factors for this Assessable
    /// - Returns: Void
    func clear() -> Void {
        self.factors = []
        self.score = 0
        self.weight = .empty
    }
    
    /// Calculates the score based on the weight, threshold and entity count factors of a given assessment factor
    /// - Returns:Void
    func calculateScore() -> Void {
        self.score = 0
        for factor in self.factors {
            factor.count = factor.countFactors(using: self.moc!, for: self.date)

            let weighted = Int64(factor.count * factor.weight)

            if weighted >= factor.threshold {
                self.score += Int(weighted)
            }
        }
    }

    /// Determines the factor's weight
    /// - Returns: Void
    func weigh(with statuses: [AssessmentThreshold]) -> Void {
        for (idx, status) in statuses.enumerated() {
            if (idx + 1) < statuses.count {
                let nextStatus =  statuses[idx + 1]
                let bounds = (nextStatus.value, status.value - 1)
                if self.score >= bounds.0 && self.score <= bounds.1 {
                    if let label = status.label {
                        if let weight = ActivityWeight.typeFromLabel(label: label) {
                            self.weight = weight
                        }
                    }
                }
            }
        }

        if let heaviestStatus = statuses.sorted(by: {$0.defaultValue > $1.defaultValue}).first {
            if self.score > heaviestStatus.defaultValue {
                self.weight = .significant
            }
        }
    }
    
    /// Weigh and score the factors
    /// - Returns: Void
    func evaluate(with statuses: [AssessmentThreshold]? = nil) -> Void {
        self.calculateScore()
        
        var stats: [AssessmentThreshold] = []
        if statuses != nil {
            stats = statuses!
        } else {
            stats = self.statuses
        }

        if stats.count > 0 && self.score > 0 {
            self.weigh(with: stats)
        }
    }

    // @TODO: activeToggle(), threshold(), weight() probably shouldn't exist (or, shouldn't exist here anyways)
    /// Modify and save the active status on a given AssessmentFactor
    /// - Parameter factor: AssessmentFactor
    /// - Returns: Void
    func activeToggle(factor: AssessmentFactor) -> Void {
        factor.alive.toggle()
        PersistenceController.shared.save()
//        self.evaluate()
    }
    
    /// Modify and save the threshold of a given AssessmentFactor
    /// - Parameters:
    ///   - factor: AssessmentFactor
    ///   - threshold: Int
    /// - Returns: Void
    func threshold(factor: AssessmentFactor, threshold: Int) -> Void {
        factor.threshold = Int64(threshold)
        PersistenceController.shared.save()
//        self.evaluate()
    }
    
    /// Modify and save the weight for a given AssessmentFactor
    /// - Parameters:
    ///   - factor: AssessmentFactor
    ///   - weight: Int
    /// - Returns: Void
    func weight(factor: AssessmentFactor, weight: Int) -> Void {
        factor.weight = Int64(weight)
        PersistenceController.shared.save()
//        self.evaluate()
    }
}
