//
//  LogRowEmpty.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

struct LogRowEmpty: View, Identifiable {
    @EnvironmentObject private var state: Navigation
    public let id = UUID()
    public var message: String
    
    var body: some View {
        HStack(spacing: 1) {
            Spacer()
            Text(self.message)
                .foregroundColor([.classic, .opaque, .hybrid].contains(self.state.theme.style) ? .gray : self.state.session.appPage.primaryColour)
                .padding(8)
            Spacer()
        }
        .background(self.PageBackground)
    }

    @ViewBuilder private var PageBackground: some View {
        ZStack {
            if [.classic, .opaque, .hybrid].contains(self.state.theme.style) {
                self.state.session.appPage.primaryColour
            } else {
                self.state.session.appPage.primaryColour.opacity(0.3)
            }
        }
    }
}
