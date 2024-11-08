//
//  Project.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-01-08.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

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

    var pageType: Page { .projects }
    var pageDetailType: Page { .projectDetail }

    @ViewBuilder var linkRowView: some View {
        HStack {
            Text(self.name ?? "Error: Invalid project name")
            Spacer()
            Image(systemName: "chevron.right")
        }
        .foregroundStyle(self.backgroundColor.isBright() ? Theme.base : .white)
        .padding(8)
        .background(self.backgroundColor)
        // @TODO: view cuts off and can't be read sometimes
//        .background(TypedListRowBackground(colour: self.backgroundColor, type: .projects))
    }
}
