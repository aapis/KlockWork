//
//  Planning.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-10.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct Planning: View {
    private let maxItems: Int = 6

//    @State private var jobs: [Job] = []

    @EnvironmentObject public var nav: Navigation

    private var columns: [GridItem] {
        Array(repeating: .init(.flexible(minimum: 100)), count: 2)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Title(text: "Planning")
                Spacer()
            }

            FancySubTitle(text: "What am I working on today?")

            WorkingOnToday

            FancySubTitle(text: "Daily Summary")
        }
        .background(Theme.cYellow)
        .onAppear(perform: actionOnAppear)
    }

    private var WorkingOnToday: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 5) {
                ScrollView(.vertical, showsIndicators: false) {
                    AllJobsPickerWidget(location: .content)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Statistics()
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: columns, alignment: .leading) {
                            let jobs = Array(nav.session.planning.jobs) //.sorted(by: {$0.jid > $1.jid})
                            ForEach(jobs) { job in
                                if nav.session.planning.jobs.count <= maxItems {
                                    Item(job: job, index: jobs.firstIndex(of: job))
                                }
                            }
                        }
                        .padding(.trailing, 20)
                    }
                }
            }
        }
        .padding()
    }
}

extension Planning {
    private func actionOnAppear() -> Void {

    }
}

extension Planning {
    struct Item: View {
        public var job: Job
        public var index: Int?

        @State private var colour: Color = .clear
        @State private var highlighted: Bool = false

        @EnvironmentObject public var nav: Navigation

        var body: some View {
            ZStack {
                Color.fromStored(job.colour!)

                VStack(alignment: .center) {
                    HStack {
                        if let idx = index {
                            Image(systemName: highlighted ? "\(idx).circle.fill" : "\(idx).circle")
                                .font(.title)
                        }

                        Spacer()
                        Button {
                            nav.session.planning.jobs.remove(job)
                        } label: {
                            Image(systemName: highlighted ? "clear.fill" : "clear")
                                .font(.title)
                        }
                        .buttonStyle(.plain)
                        .useDefaultHover({inside in highlighted = inside})
                    }

                    Spacer()

                    if let tasks = job.tasks {
                        Text(tasks.count.string)
                            .font(.title)
                            .foregroundColor(colour.isBright() ? .black : .white)
                    }

                    Text(job.jid.string)
                        .foregroundColor(colour.isBright() ? .black : .white)
                    Spacer()
                }
            }
            .frame(minHeight: 150)
            .mask(RoundedRectangle(cornerRadius: 5))
        }


    }
}

extension Planning.Item {

}

extension Planning {
    struct Statistics: View {
        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack {
                HStack {
                    Text("\(nav.session.planning.taskCount()) Tasks")
                    Text("\(nav.session.planning.jobs.count.string) Jobs")
                }
            }
            .background(.green)
        }
    }
}

extension Planning.Statistics {

}
