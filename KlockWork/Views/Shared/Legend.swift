//
//  Legend.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-11.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct Statuses: Equatable, Identifiable {
    var id: UUID = UUID()
    var list: [AssessmentThreshold]
}

struct Legend: View {
    @EnvironmentObject private var state: Navigation
    @Binding public var id: UUID
    @Binding public var calendarId: UUID
    @State private var isSheetPresented: Bool = false
    private var columns: [GridItem] {
        return Array(repeating: GridItem(.flexible(), spacing: 1), count: 3)
    }

    var body: some View {
        GridRow {
            VStack(alignment: .leading) {
                GridRow {
                    HStack(alignment: .center) {
                        LegendLabel(label: "Legend")

                        // Legend settings/gear button
                        Button {
                            self.isSheetPresented.toggle()
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "gear")
                            }
                        }
                        .foregroundStyle(self.state.activities.statuses.isEmpty ? .gray : self.state.theme.tint)
                        .help("Modify assessment factors")
                        .disabled(self.state.activities.statuses.isEmpty)
                    }
                }
                .padding([.bottom], 10)
                LazyVGrid(columns: columns, alignment: .leading) {
                    ForEach(self.state.activities.statuses.sorted(by: {$0.defaultValue < $1.defaultValue})) { status in
                        Row(status: status)
                    }
                    RowBasic(colour: self.state.theme.tint, label: "Today")
                    RowBasic(colour: .blue, label: "Selected")
                }
            }
        }
        .padding()
//        .background(Theme.textBackground)
//        .sheet(isPresented: $isSheetPresented) {
//            NavigationStack {
//                AssessmentThresholdForm()
//                    .onDisappear(perform: self.actionOnDisappear)
//            }
//            .presentationDetents([.medium, .large])
//            .scrollDismissesKeyboard(.immediately)
//        }
    }
}

extension Legend {
    struct Row: View {
        public var status: AssessmentThreshold
        @State private var colour: Color = .clear
        @State private var label: String = "_LABEL_TEXT"
        @State private var emoji: String = "🏖️"

        var body: some View {
            RowBasic(
                colour: colour,
                label: label,
                emoji: emoji
            )
            .onAppear(perform: {
                if let col = self.status.colour {
                    self.colour = Color.fromStored(col)
                }

                if let lab = self.status.label {
                    self.label = lab
                }

                if let emo = self.status.emoji {
                    self.emoji = emo
                }
            })
        }
    }

    struct RowBasic: View {
        public var colour: Color?
        public var label: String
        public var emoji: String? = "🏖️"

        var body: some View {
            VStack {
                HStack(alignment: .center, spacing: 5) {
                    Rectangle()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(colour!)
                        .border(width: 1, edges: [.top, .bottom, .leading, .trailing], color: .gray)

                    Text(label)
                        .font(.caption)
                }
            }
        }
    }
}

extension Legend {
    /// Callback handler, fired when the OverviewWidget sheet is closed
    /// - Returns: Void
    private func actionOnDisappear() -> Void {
        self.id = UUID()
        self.calendarId = UUID()
    }
}
