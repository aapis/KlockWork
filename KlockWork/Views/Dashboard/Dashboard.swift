//
//  Dashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore
import EventKit

struct Dashboard: View {
    static public let id: UUID = UUID()
    private let page: PageConfiguration.AppPage = .find
    @State public var searching: Bool = false

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var updater: ViewUpdater
    
    @AppStorage("CreateEntitiesWidget.isSearchStackShowing") private var isSearchStackShowing: Bool = false
    
    @FocusState private var primaryTextFieldInFocus: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FindDashboard(location: .content)
            Spacer()
        }
        .padding()
        .background(Theme.toolbarColour)
    }
}
