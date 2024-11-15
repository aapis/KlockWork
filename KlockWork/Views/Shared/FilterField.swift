//
//  FilterField.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-30.
//  Copyright © 2024 YegCollective. All rights reserved.
//


import SwiftUI
import KWCore

struct FilterField: Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var options: [FilterOptionPair] = []

    /// Equatable implementation
    /// - Parameters:
    ///   - lhs: FilterField
    ///   - rhs: FilterField
    /// - Returns: Bool
    static func == (lhs: FilterField, rhs: FilterField) -> Bool {
        return lhs.id == rhs.id
    }
}

struct FilterOptionPair: Identifiable {
    var id: UUID = UUID()
    var key: String
    var value: Any
}

struct FilterFieldView: View {
    @EnvironmentObject private var state: Navigation
    var filter: FilterField
    var callback: ((FilterField) -> Void)?

    var body: some View {
        Button {
            self.callback?(self.filter)
        } label: {
            HStack(alignment: .center, spacing: 8) {
                Text(filter.name)
                Image(systemName: "xmark.square.fill")
            }
            .foregroundStyle(self.state.theme.tint)
            .padding(3)
            .background(.white.opacity(0.7).blendMode(.softLight))
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .font(Theme.fontCaption)
        }
    }
}

struct TermsGroupedByDate: Identifiable {
    var id: UUID = UUID()
    var date: Date
    var definitions: [TaxonomyTermDefinitions]
}

struct GroupedTermDateRow: View {
    public let date: Date

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Image(systemName: "calendar")
            Text(date.formatted(date: .abbreviated, time: .omitted))
            Spacer()
        }
        .padding(8)
    }
}

/// Thank you https://stackoverflow.com/a/64496966
extension Array {
  func sliced(by dateComponents: Set<Calendar.Component>, for key: KeyPath<Element, Date>) -> [Date: [Element]] {
    let initial: [Date: [Element]] = [:]
    let groupedByDateComponents = reduce(into: initial) { acc, cur in
      let components = Calendar.current.dateComponents(dateComponents, from: cur[keyPath: key])
      let date = Calendar.current.date(from: components)!
      let existing = acc[date] ?? []
      acc[date] = existing + [cur]
    }

    return groupedByDateComponents
  }
}
