//
//  LinkDashboard.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct FindDashboard: View {
    @State private var searchText: String = ""
//    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                search.font(Theme.font)

                Spacer()
            }
            .padding()
        }
        .background(Theme.toolbarColour)
    }
    
    @ViewBuilder
    var search: some View {
        HStack {
            Title(text: "Find", image: "magnifyingglass")
            Spacer()
        }
        
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                HStack(spacing: 0) {
                    Group {
                        ZStack {
                            Theme.headerColour
                        }
                    }
                    
                    Group {
                        ZStack {
                            Theme.headerColour
                            
                            Text("jo")
                        }
                    }
                    
                }
                .frame(height: 40)
            }
            
            GridRow {
                SearchBar(
                    text: $searchText,
                    disabled: false,
                    placeholder: "Search"
                )
            }
            
            Results(text: $searchText)
        }
    }
}
