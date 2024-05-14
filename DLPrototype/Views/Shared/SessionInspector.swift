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
    
    @State private var form: Navigation.Forms.ThreePanelForm? = nil

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
        .onChange(of: nav.forms.tp.selected) { _ in
            form = nav.forms.tp
        }
        .frame(width: 500)
    }
}

extension SessionInspector {
    
}
