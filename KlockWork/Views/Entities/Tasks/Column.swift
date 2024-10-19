//
//  Column.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-03.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

struct CustomMessage: View, Identifiable {
    @EnvironmentObject public var state: Navigation
    public var id: UUID = UUID()
    public var word: String
    public var view: AnyView
    @FetchRequest public var term: FetchedResults<TaxonomyTerm>

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            if let term = self.term.first {
                Button {
                    if self.term.count == 1 {
                        self.state.session.search.inspectingEntity = term
                        self.state.setInspector(AnyView(Inspector(entity: term)))
                    }
                } label: {
                    HStack(alignment: .center, spacing: 0) {
                        self.view
                            .underline(self.term.first?.alive ?? false)
                    }
                }
                .useDefaultHover({_ in})
                .buttonStyle(.plain)

                if self.term.count > 1 {
                    Image(systemName: "questionmark.square.fill")
                }
            } else {
                self.view
            }
        }
        .multilineTextAlignment(.leading)
    }

    init(word: String, view: AnyView) {
        self.word = word
        self.view = view
        _term = CoreDataTaxonomyTerms.fetchExactMatch(name: word)
    }
}

struct Column: View {
    public var type: RecordTableColumn = .message
    public var colour: Color
    public var textColour: Color
    public var index: Array<Entry>.Index?
    public var alignment: Alignment = .leading
    public var url: URL?
    public var job: Job?
    public var show: Bool = true
    @State private var words: [CustomMessage] = []

    @Binding public var text: String

    @EnvironmentObject public var nav: Navigation
    @StateObject public var jm: CoreDataJob = CoreDataJob(moc: PersistenceController.shared.container.viewContext)

    @AppStorage("tigerStriped") private var tigerStriped = false

    var body: some View {
        if self.show {
            Group {
                ZStack(alignment: alignment) {
                    colour
                    switch type {
                    case .index:
                        Index
                    case .timestamp:
                        Timestamp
                    case .extendedTimestamp:
                        ExtendedTimestamp
                    case .job:
                        Job
                    case .message:
                        Message
                    }
                }
            }
            .onAppear(perform: self.actionOnAppear)
        }
    }

    @ViewBuilder private var Timestamp: some View {
        Text(formatted())
            .padding(10)
            .foregroundColor(textColour)
    }

    @ViewBuilder private var ExtendedTimestamp: some View {
        Text(text)
            .padding(10)
            .foregroundColor(textColour)
    }

    @ViewBuilder private var Job: some View {
        HStack {
            if job != nil {
                Button {
                    self.nav.session.job = self.job
                    self.nav.to(.jobs)
                } label: {
                    Text(text.replacingOccurrences(of: ".0", with: ""))
                        .foregroundColor(colour.isBright() ? Theme.base : Color.white)

                        .help("Edit job")
                }
                .useDefaultHover({_ in})
                .buttonStyle(.plain)
                .underline()
            }

            // TODO: move to new statuses column
//            if job!.shredable {
//                Image(systemName: "dollarsign.circle")
//                    .foregroundColor(colour.isBright() ? Theme.base : Color.white)
//                    .help("Eligible for SR&ED")
//            }
        }
        .padding([.leading, .trailing], 10)
    }

    @ViewBuilder private var Index: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(self.job == self.nav.session.job ? .yellow : Theme.cPurple.opacity(0.8))
                .frame(height: 23)
            Text(self.text)
                .opacity(0.5)
                .foregroundStyle((self.job == self.nav.session.job ? Theme.base : .white).opacity(0.55))
                .font(.system(.subheadline, design: .monospaced))
        }
        .padding(6)
    }

    @ViewBuilder private var MessageEXPERIMENTAL: some View {
        HStack(alignment: .top, spacing: 3) {
            if self.words.count < 60 {
                ForEach(self.words, id: \.id) { word in word }
            } else {
                Text(self.text)
            }
        }
//        .fixedSize(horizontal: false, vertical: true)
        .foregroundStyle(self.textColour)
        .help(self.text)
    }

    @ViewBuilder private var Message: some View {
        Text(text)
            .padding(10)
            .foregroundStyle(textColour)
            .help(text)
    }
}

extension Column {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        let wordsFromText = self.text.split(separator: /\s/)

        for word in wordsFromText {
            self.words.append(
                CustomMessage(
                    word: String(word),
                    view: AnyView(
                        Text(word)
                            .lineLimit(4)
//                            .fixedSize(horizontal: true, vertical: true)
                    )
                )
            )
        }
    }
    
    /// Formats date for UI
    /// - Returns: String
    private func formatted() -> String {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.timeZone = TimeZone.autoupdatingCurrent
        inputDateFormatter.locale = NSLocale.current
        inputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let inputDate = inputDateFormatter.date(from: text)

        if inputDate == nil {
            return "Invalid date"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = inputDateFormatter.timeZone
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "h:mm a"

        return dateFormatter.string(from: inputDate!)
    }
}
