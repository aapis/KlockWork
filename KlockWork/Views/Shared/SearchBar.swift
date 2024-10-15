//
//  SearchBar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

// @TODO: REMOVE ME, deprecated (replaced by UI.SearchBar/.BoundSearchBar
struct SearchBar: View {
    @EnvironmentObject public var state: Navigation
    @AppStorage("searchbar.showTypes") private var showingTypes: Bool = false
    @AppStorage("searchbar.shared") private var searchText: String = ""
    @AppStorage("CreateEntitiesWidget.isSearchStackShowing") private var isSearchStackShowing: Bool = false
    @AppStorage("isDatePickerPresented") public var isDatePickerPresented: Bool = false
    @Binding public var text: String
    public var disabled: Bool = false
    public var placeholder: String? = "Search..."
    public var onSubmit: (() -> Void)? = nil
    public var onReset: (() -> Void)? = nil
    @FocusState private var primaryTextFieldInFocus: Bool

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
                            action: self.actionOnReset,
                            icon: "xmark",
                            showLabel: false,
                            showIcon: true,
                            type: .white
                        )
                    } else {
                        FancyButtonv2(
                            text: "Entities",
                            action: {self.showingTypes.toggle()},
                            icon: self.showingTypes ? "arrow.up.square.fill" : "arrow.down.square.fill",
                            showLabel: false,
                            type: .white
//                            type: .clear,
//                            font: .title2
                        )
                        .help("Choose the entities you want to search")
                    }
                }
                .padding([.leading, .trailing])
            }
            .frame(height: 57)
        }
        .background(self.state.session.job?.backgroundColor.opacity(0.6) ?? Theme.textBackground)
        .onAppear(perform: self.actionOnAppear)
    }
}

extension SearchBar {
    /// Onload handler. Starts monitoring keyboard for esc key
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        print("Remove me") // @TODO: KeyboardHelper.monitor doesn't seem to run if it's the only contents of this method
//        KeyboardHelper.monitor(key: .keyDown, callback: {
//            self.actionOnReset()
//        })
        print("Remove me after") // @TODO: KeyboardHelper.monitor doesn't seem to run if it's the only contents of this method
    }
    /// Reset field text
    /// - Returns: Void
    private func actionOnReset() -> Void {
        self.text = ""

        if onReset != nil {
            onReset!()
        }
    }
}


