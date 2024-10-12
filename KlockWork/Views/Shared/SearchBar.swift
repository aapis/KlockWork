//
//  SearchBar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

struct SearchBar: View {
    @EnvironmentObject public var state: Navigation
    @Binding public var text: String
    public var disabled: Bool = false
    public var placeholder: String? = "Search..."
    public var onSubmit: (() -> Void)? = nil
    public var onReset: (() -> Void)? = nil
    @AppStorage("searchbar.showTypes") private var showingTypes: Bool = false
    @FocusState private var primaryTextFieldInFocus: Bool
    // @TODO: this will remember the search text between pages, but I think instead I need some kind of search history
//    @AppStorage("shared.searchbar") private var text: String = ""
    
    var body: some View {
        GridRow {
            ZStack(alignment: .trailing)  {
                FancyTextField(placeholder: placeholder!, lineLimit: 1, onSubmit: onSubmit, transparent: true, disabled: disabled, font: .title3, text: $text)
                    .padding(.leading, 35)
                    .focused($primaryTextFieldInFocus)
                    .onAppear {
                        // thx https://www.kodeco.com/31569019-focus-management-in-swiftui-getting-started#toc-anchor-002
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.primaryTextFieldInFocus = true
                        }
                    }

                HStack(alignment: .center) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                    Spacer()
                    if text.count > 0 {
                        FancySimpleButton(
                            text: "Reset",
                            action: reset,
                            icon: "xmark",
                            showLabel: false,
                            showIcon: true,
                            type: .white
                        )
                    } else {
                        FancyButtonv2(
                            text: "Entities",
                            action: {showingTypes.toggle()},
                            icon: showingTypes ? "arrow.up.square.fill" : "arrow.down.square.fill",
                            showLabel: false,
                            type: .clear,
                            font: .title2
                        )
                        .help("Choose the entities you want to search")
                    }
                }
                .padding([.leading, .trailing])
            }
            .frame(height: 57)
        }
        .background(self.state.session.job?.backgroundColor.opacity(0.6) ?? Theme.textBackground)
    }
}

extension SearchBar {
    private func reset() -> Void {
        text = ""

        if onReset != nil {
            onReset!()
        }
    }
}
