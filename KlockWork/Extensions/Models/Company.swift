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
}
