//
//  Company.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-01.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension Company {
    var backgroundColor: Color {
        if let c = self.colour {
            return Color.fromStored(c)
        }

        return Color.clear
    }

    var pageType: Page { .companies }
    var pageDetailType: Page { .companyDetail }

    var defaultProject: Project? {
        if let company = CoreDataCompanies(moc: PersistenceController.shared.container.viewContext).findDefault() {
            if let projects = company.projects?.allObjects as? [Project] {
                if projects.count > 0 {
                    return projects.sorted(by: {$0.created ?? Date() > $1.created ?? Date()}).first
                }
            }
        }

        return nil
    }
}
