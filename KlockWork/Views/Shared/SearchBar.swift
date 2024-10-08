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
    @FocusState private var primaryTextFieldInFocus: Bool
    // @TODO: this will remember the search text between pages, but I think instead I need some kind of search history
//    @AppStorage("shared.searchbar") private var text: String = ""
    
    var body: some View {
        GridRow {
            ZStack(alignment: .trailing) {
                FancyTextField(placeholder: placeholder!, lineLimit: 1, onSubmit: onSubmit, disabled: disabled, text: $text)
                    .focused($primaryTextFieldInFocus)
                    .onAppear {
                        // thx https://www.kodeco.com/31569019-focus-management-in-swiftui-getting-started#toc-anchor-002
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.primaryTextFieldInFocus = true
                        }
                    }

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
                    .padding([.trailing])
                }
            }
        }
        .background(self.state.session.job?.backgroundColor.opacity(0.6) ?? .clear)
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
