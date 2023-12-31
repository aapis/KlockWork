//
//  NoteFormWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct NoteFormWidget: View {
    @State private var selection: Int = 0
    
    @StateObject private var templates: NoteTemplates()

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Create a new note")
                Spacer()
            }
            HStack {
                Picker("Template", selection: $selection) {
                    ForEach(Template.allCases, id: \.self) { config in
                        Text(config)
                    }
                }
            }
        }
        .padding(8)
        .background(Theme.base.opacity(0.2))
    }
}
