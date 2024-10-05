//
//  Column.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-03.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct Column: View {
    public var type: RecordTableColumn = .message
    public var colour: Color
    public var textColour: Color
    public var index: Array<Entry>.Index?
    public var alignment: Alignment = .leading
    public var url: URL?
    public var job: Job?
    public var show: Bool = true

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
                    nav.view = AnyView(JobDashboard(defaultSelectedJob: job!))
                    nav.parent = .jobs
                    nav.sidebar = AnyView(JobDashboardSidebar())
                    nav.pageId = UUID()
                } label: {
                    Text(text.replacingOccurrences(of: ".0", with: ""))
                        .foregroundColor(colour.isBright() ? Color.black : Color.white)

                        .help("Edit job")
                }
                .useDefaultHover({_ in})
                .buttonStyle(.plain)
                .underline()
            }

            // TODO: move to new statuses column
//            if job!.shredable {
//                Image(systemName: "dollarsign.circle")
//                    .foregroundColor(colour.isBright() ? Color.black : Color.white)
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

    @ViewBuilder private var Message: some View {
        Text(text)
            .padding(10)
            .foregroundColor(textColour)
            .help(text)
    }

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
