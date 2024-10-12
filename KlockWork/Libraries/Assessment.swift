//
//  Assessment.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-11.
//  Copyright © 2024 YegCollective. All rights reserved.
//


import SwiftUI
import KWCore
import CoreData

class Assessment {
    typealias EntityType = PageConfiguration.EntityType
    typealias Statuses = [AssessmentThreshold]

    var assessables: Assessables = Assessables()
    var date: Date
    var dayNumber: Int = 0
    var isSelected: Bool = false
    var isWeekend: Bool = false
    var moc: NSManagedObjectContext
    var score: Int = 0
    var searchTerm: String = "" // @TODO: will have to refactor a fair bit to make this possible
    var weight: ActivityWeight = .empty // @TODO: need to replace ActivityWeight with AssessmentThreshold somehow
    var statuses: Statuses = []
    var isToday: Bool {Calendar.autoupdatingCurrent.isDateInToday(self.date)}

    init(assessmentStatuses: inout Statuses, date: Date, dayNumber: Int = 0, isSelected: Bool = false, isWeekend: Bool = false, moc: NSManagedObjectContext, searchTerm: String = "") {
        self.date = date
        self.dayNumber = dayNumber
        self.isSelected = isSelected
        self.isWeekend = isWeekend
        self.moc = moc
        self.searchTerm = searchTerm
        self.statuses = assessmentStatuses
        self.assessables.date = self.date
        self.assessables.moc = self.moc

        // Create all the AssessmentFactor objects
        self.assessables.factors = CDAssessmentFactor(moc: self.moc).all()

        for factor in self.assessables.factors {
            factor.date = self.date
            factor.count = factor.countFactors(using: self.moc)
        }

        // Perform the assessment by iterating over all the things and calculating the score
        self.assessables.evaluate(with: self.statuses)
        self.weight = self.assessables.weight
        self.score = self.assessables.score
    }

    func backgroundColourFromWeight() -> Color {
        var colour: Color = self.weight.colour
        if let status = self.statuses.first(where: {$0.label == self.weight.label}) {
            if let color = status.colour {
                colour = Color.fromStored(color)
            }
        }

        if self.isToday {
            return .yellow // leave this .yellow so we don't need to pass in state.theme.tint
        } else if self.isSelected {
            return .blue
        } else {
            if self.isWeekend {
                // IF we worked on the weekend, highlight the tile in red (this is bad and should be highlighted)
                if self.weight != .empty {
                    return .red
                } else {
                    return .clear
                }
            } else {
                return colour
            }
        }
    }
}
