//
//  Project.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-01-08.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

extension Project {
//    func field() -> Navigation.Forms.Field {
//        let field = Navigation.Forms.Field(type: .dropdown)
//
//        
//
//        return field
//    }

    var cBackgroundColor: Color {
        if let c = self.company?.colour {
            return Color.fromStored(c)
        }

        return Color.clear
    }

    var backgroundColor: Color {
        if let c = self.colour {
            return Color.fromStored(c)
        }

        return Color.clear
    }
}
