//
//  CompanyView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct CompanyView: View {
    public var company: Company?
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 13) {
                TopBar

                HStack(alignment: .top, spacing: 5) {
                    VStack(alignment: .leading) {
                        FancyTextField(placeholder: "Title", lineLimit: 1, onSubmit: {}, disabled: revisionNotLatest(), text: $title)
                        FancyTextField(placeholder: "Content", lineLimit: 20, onSubmit: {}, transparent: true, disabled: revisionNotLatest(), text: $content)
                            .scrollIndicators(.never)
                    }

                    if sidebarVisible {
                        SideBar
                    }
                }

                HelpBar
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .onAppear(perform: {createBindings(note: note)})
        .onChange(of: note, perform: createBindings)
    }

}

//struct CompanyView_Previews: PreviewProvider {
//    static var previews: some View {
//        CompanyView()
//    }
//}
