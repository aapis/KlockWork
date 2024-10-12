//
//  Day.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-11.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

/// An individual calendar day "tile"
struct Day: View, Identifiable {
    @EnvironmentObject private var state: Navigation
    public let id: UUID = UUID()
    public var assessment: Assessment
    public var onCloseCallback: () -> Void
    @State private var bgColour: Color = .clear
    @State private var isPresented: Bool = false
    private let gridSize: CGFloat = 40

    var body: some View {
        Button {
            self.state.session.date = DateHelper.startOfDay(assessment.date)
            isPresented.toggle()
        } label: {
            if self.assessment.dayNumber > 0 {
                Text(String(self.assessment.dayNumber))
            }
        }
        .buttonStyle(.plain)
        .frame(minWidth: self.gridSize, minHeight: self.gridSize)
        .background(self.assessment.dayNumber > 0 ? self.bgColour : .clear)
        .foregroundColor(self.assessment.isToday || self.bgColour.isBright() ? Theme.cGreen : .white)
        .clipShape(.rect(cornerRadius: 6))
        .onAppear(perform: self.actionOnAppear)
//        .sheet(isPresented: $isPresented) {
//            Panel(assessment: assessment)
//                .onDisappear(perform: self.onCloseCallback)
//        }
    }
}

extension Day {
    /// Onload handler, determines tile background colour
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.bgColour = self.assessment.backgroundColourFromWeight()
    }
}
