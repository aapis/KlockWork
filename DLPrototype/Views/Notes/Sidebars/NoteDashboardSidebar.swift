//
//  NoteDashboardSidebar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct NoteDashboardSidebar: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 5) {
                NoteSearchWidget()
                FavouriteNotesWidget()
            }
            Spacer()
        }
        .padding()
    }
}
