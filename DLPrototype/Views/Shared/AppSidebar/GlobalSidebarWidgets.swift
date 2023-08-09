//
//  Sidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-08.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct GlobalSidebarWidgets: View {
    @Binding public var isDatePickerPresented: Bool
    
    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DateSelectorWidget(isDatePickerPresented: $isDatePickerPresented)
            CreateEntitiesWidget(isDatePickerPresented: $isDatePickerPresented)
        }
    }
}

extension GlobalSidebarWidgets {
    private func formattedDate() -> String {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        return df.string(from: nav.session.date)
    }
}
