//
//  Sidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-08.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct GlobalSidebarWidgets: View {
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        ZStack(alignment: .topLeading) {
            CreateEntitiesWidget()
                .padding(.top, 53)
            DateSelectorWidget()
        }
    }
}
