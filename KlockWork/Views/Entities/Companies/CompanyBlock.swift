//
//  CompanyBlock.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct CompanyBlock: View {
    public var company: Company

    @State private var highlighted: Bool = false

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        Button {
            nav.setView(AnyView(CompanyView(company: company)))
            nav.setSidebar(AnyView(DefaultCompanySidebar()))
            nav.setParent(.companies)
            nav.setId()
        } label: {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    (company.alive && company.colour != nil ? Color.fromStored(company.colour!) : Color.white)
                        .shadow(color: .black.opacity(1), radius: 3)
                        .opacity(highlighted ? 0.4 : 0.3)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            if company.isDefault {
                                Image(systemName: "building.2")
                                    .help("Default company")
                            }
                            Text(company.name!.capitalized)
                                .font(.title3)
                                .fontWeight(.bold)
                        }

                        Text("\(company.projects?.count ?? 0) Projects")
                        Spacer()
                    }
                    .padding([.leading, .trailing, .top])
                }
            }
        }
        .useDefaultHover({inside in highlighted = inside})
        .buttonStyle(.plain)
    }
}
