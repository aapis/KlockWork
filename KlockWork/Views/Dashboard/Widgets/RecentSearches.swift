//
//  RecentSearches.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-11.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct RecentSearches {
    struct SearchWidget: View {
        @EnvironmentObject public var state: Navigation
        @AppStorage("dashboard.widget.recentSearches") public var showRecentSearches: Bool = true
        public let title: String = "Recent Searches"
        public var page: PageConfiguration.AppPage = .find

        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    FancySubTitle(text: "\(title)", fgColour: .white)
                    Spacer()
                    FancyButtonv2(
                        text: "Close",
                        action: self.actionOnCloseWidget,
                        icon: "xmark",
                        showLabel: false,
                        showIcon: true,
                        size: .tiny,
                        type: .clear
                    )
                }
                .padding()
                .background(Theme.darkBtnColour)

                ForEach(Array(self.state.session.search.history), id: \.self) { searchTerm in
                    Button {
                        self.actionOnTap(term: searchTerm)
                    } label: {
                        HStack {
                            Text(searchTerm)
                            Spacer()
                        }
                        .padding(5)
                        .useDefaultHover({_ in})
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(self.state.session.appPage.primaryColour)
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: self.state.session.search.history) { self.actionOnAppear() }
        }
    }

    struct Widget: View {
        @EnvironmentObject public var state: Navigation
        @AppStorage("dashboard.widget.recentSearches") public var showRecentSearches: Bool = true
        public let title: String = "Recent Searches"
        public var page: PageConfiguration.AppPage = .find

        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    FancySubTitle(text: "\(title)", fgColour: .white)
                    Spacer()
                    FancyButtonv2(
                        text: "Close",
                        action: self.actionOnCloseWidget,
                        icon: "xmark",
                        showLabel: false,
                        showIcon: true,
                        size: .tiny,
                        type: .clear
                    )
                }
                .padding()
                .background(Theme.darkBtnColour)

                ForEach(Array(self.state.session.search.history), id: \.self) { searchTerm in
                    Button {
                        self.actionOnTap(term: searchTerm)
                    } label: {
                        HStack {
                            Text(searchTerm)
                            Spacer()
                        }
                        .padding(5)
                        .useDefaultHover({_ in})
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(self.state.session.appPage.primaryColour)
    //        .frame(height: 250)
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: self.state.session.search.history) { self.actionOnAppear() }
        }
    }
}

extension RecentSearches.Widget {
    /// Onload handler. Creates forecast
    /// - Returns: Void
    private func actionOnAppear() -> Void {

    }
    
    /// Sets the current search term to the selected text
    /// - Parameter term: String
    /// - Returns: Void
    private func actionOnTap(term: String) -> Void {
        self.state.session.search.text = term
    }

    private func actionOnCloseWidget() -> Void {
        
    }
}

extension RecentSearches.SearchWidget {
    /// Onload handler. Creates forecast
    /// - Returns: Void
    private func actionOnAppear() -> Void {

    }

    /// Sets the current search term to the selected text
    /// - Parameter term: String
    /// - Returns: Void
    private func actionOnTap(term: String) -> Void {
        self.state.session.search.text = term
    }

    private func actionOnCloseWidget() -> Void {

    }
}
