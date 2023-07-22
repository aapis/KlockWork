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

    @EnvironmentObject public var jm: CoreDataJob
    @EnvironmentObject public var updater: ViewUpdater

    var body: some View {
        NavigationLink {
            CompanyView(company: company)
                .environmentObject(jm)
                .environmentObject(updater)
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
                            .padding([.leading, .trailing, .top])
                        Spacer()
                    }
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
