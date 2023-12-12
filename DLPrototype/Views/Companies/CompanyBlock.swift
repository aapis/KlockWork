//
//  CompanyBlock.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct CompanyBlock: View {
    public var company: Company

    @State private var highlighted: Bool = false

    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var jm: CoreDataJob
    @EnvironmentObject public var updater: ViewUpdater

    var body: some View {
        Button {
            nav.view = AnyView(CompanyView(company: company))
            nav.parent = .companies
        } label: {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    (company.alive ? Color.yellow : Color.white)
                        .shadow(color: .black.opacity(1), radius: 3)
                        .opacity(highlighted ? 0.2 : 0.1)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(company.name!)
                            .font(.title3)
                            .fontWeight(.bold)

                        Text("\(company.projects?.count ?? 0) Projects")
                        Text("0 Jobs")
                        Spacer()
                    }
                    .padding([.leading, .trailing, .top])
                }
            }
        }
        .onHover { inside in
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }

            highlighted.toggle()
        }
        .buttonStyle(.plain)
    }
}

//struct CompanyBlock_Previews: PreviewProvider {
//    static var previews: some View {
//        CompanyBlock()
//    }
//}
