//
//  CompanyView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct CompanyView: View {
    public var company: Company

    @State private var name: String = ""
    @State private var abbreviation: String = ""
    @State private var isDeleteAlertShowing: Bool = false

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    Title(text: "Editing: \(company.name!.capitalized)")
                    Spacer()

                    if company.isDefault {
                        Image(systemName: "building.2")
                            .help("This is your default company. Change it in Settings > General")
                    }
                }

                FancyTextField(placeholder: "Legal name", lineLimit: 1, onSubmit: {}, text: $name)
                FancyTextField(placeholder: "Abbreviation (i.e. City of New York = CONY)", lineLimit: 1, onSubmit: {}, text: $abbreviation)
                FancyDivider()

                ManageOwnedProjects(company: company)

                HStack {
                    FancyButtonv2(
                        text: "Delete",
                        action: {isDeleteAlertShowing = true},
                        icon: "trash",
                        showLabel: false,
                        type: .destructive
                    )
                    .alert("Are you sure you want to delete company \(company.name ?? "Invalid company name")?", isPresented: $isDeleteAlertShowing) {
                        Button("Yes", role: .destructive) {
                            actionSoftDelete()
                        }
                        Button("No", role: .cancel) {}
                    }
                    
                    Spacer()
                    FancyButtonv2(
                        text: "Save",
                        action: save,
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
        .background(Theme.toolbarColour)
        .onAppear(perform: actionOnAppear)
        .onChange(of: name) { newName in
            abbreviation = StringHelper.abbreviate(newName)

            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
                self.save()
                timer.invalidate()
            }
        }
        .onChange(of: company) { newCompany in
            name = newCompany.name!
            abbreviation = newCompany.abbreviation!
        }
    }
}

extension CompanyView {
    private func actionOnAppear() -> Void {
        name = company.name!
        abbreviation = company.abbreviation!
    }

    private func save() -> Void {
        company.name = name
        company.abbreviation = abbreviation

        PersistenceController.shared.save()
    }

    private func actionSoftDelete() -> Void {
        company.alive = false
        
        if let projects = company.projects {
            let pArr = projects.allObjects as! [Project]

            for project in pArr {
                project.company = nil
            }
        }

        PersistenceController.shared.save()

        nav.setId()
        nav.setView(AnyView(CompanyDashboard()))
        nav.setParent(.companies)
        nav.setSidebar(AnyView(DefaultCompanySidebar()))
    }

    private func actionHardDelete() -> Void {
        moc.delete(company)
        PersistenceController.shared.save()

        nav.setId()
        nav.setView(AnyView(CompanyDashboard()))
        nav.setParent(.companies)
        nav.setSidebar(AnyView(DefaultCompanySidebar()))
    }
}

//struct CompanyView_Previews: PreviewProvider {
//    static var previews: some View {
//        CompanyView()
//    }
//}
