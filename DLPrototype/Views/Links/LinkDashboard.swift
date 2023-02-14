//
//  LinkDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-13.
//  Copyright © 2023 YegCollective. All rights reserved.
//
import Foundation
import SwiftUI

struct LinkDashboard: View {
    @State private var searchText: String = ""
    
    @EnvironmentObject public var rm: LogRecords
    @EnvironmentObject public var updater: ViewUpdater
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                search

                Spacer()
            }
            .font(Theme.font)
            .padding()
        }
        .background(Theme.toolbarColour)
    }
    
    @ViewBuilder
    var search: some View {
        HStack {
            Title(text: "Links", image: "link")
            Spacer()
        }
        
        Grid(horizontalSpacing: 0, verticalSpacing: 1) {
            GridRow {
                SearchBar(
                    text: $searchText,
                    disabled: false,
                    placeholder: "Search"
                )
            }
            
            GridRow {
                ZStack(alignment: .leading) {
                    Theme.subHeaderColour
                    
                    HStack {
                        
                    }
                    .padding([.leading, .trailing], 10)
                }
            }
            .frame(height: 40)
            
            FancyDivider()
            
            
        }
    }
}

struct LinkDashboard_Previews: PreviewProvider {
    static var previews: some View {
        LinkDashboard()
    }
}
