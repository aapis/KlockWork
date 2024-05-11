//
//  SessionInspectorWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-01-06.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct SessionInspector: View {
    @EnvironmentObject private var nav: Navigation
    
    @State private var form: Navigation.Forms.JobSelectorForm? = nil

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                if form != nil {
                    Text("Panel: selected items: \(form!.selected.count)")
                }
                
                Text(form.debugDescription)
            }
        }
        .padding()
        .onChange(of: nav.forms.jobSelector.selected) { _ in
            form = nav.forms.jobSelector
        }
        .frame(width: 500)
    }
}

extension SessionInspector {
    
}
