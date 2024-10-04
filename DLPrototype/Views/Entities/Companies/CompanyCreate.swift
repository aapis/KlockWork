//
//  CompanyCreate.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-12.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct CompanyCreate: View {
    @EnvironmentObject public var state: Navigation
    @Environment(\.dismiss) private var dismiss
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .companies
    @State private var name: String = ""
    @State private var abbreviation: String = ""

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Title(text: "Create a company")
                    Spacer()
                }
                
                FancyTextField(placeholder: "Legal name", lineLimit: 1, onSubmit: {}, showLabel: true, text: $name)
                FancyTextField(placeholder: "Abbreviation", lineLimit: 1, onSubmit: {}, showLabel: true, text: $abbreviation)
                FancyDivider()

                HStack {
                    Spacer()
                    FancyButtonv2(
                        text: "Create",
                        action: create,
                        size: .medium,
                        redirect: AnyView(CompanyDashboard()),
                        pageType: .projects,
                        sidebar: AnyView(DefaultCompanySidebar())
                    )
                }

                Spacer()
            }
            .padding()
        }
        .background(self.page.primaryColour)
        .onChange(of: self.name) {
            self.abbreviation = StringHelper.abbreviate(self.name)
        }
    }
}

extension CompanyCreate {
    private func create() -> Void {
        let company = Company(context: moc)
        company.pid = CoreDataCompanies(moc: moc).nextPid
        company.name = name
        company.createdDate = Date()
        company.colour = Color.randomStorable()
        company.alive = true
        company.id = UUID()
        company.abbreviation = abbreviation

        PersistenceController.shared.save()
    }
}
