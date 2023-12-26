//
//  Add.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-10.
//  Copyright © 2020 YegCollective. All rights reserved.
//
import SwiftUI

struct Today: View {
    public var defaultSelectedDate: Date? = nil

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var ce: CoreDataCalendarEvent

    @FocusState private var primaryTextFieldInFocus: Bool
    
    // MARK: body view
    var body: some View {
        VStack(alignment: .leading) {
            PostingInterface()
            LogTable()
                .environmentObject(ce)
                .environmentObject(nav)
        }
        .padding()
        .background(Theme.toolbarColour)
    }
}
