//
//  Summary.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-09-01.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

extension Planning {
    struct Summary: View {
        @EnvironmentObject public var nav: Navigation

        @State private var score: Int = 1

        @FetchRequest public var records: FetchedResults<LogRecord>

        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Score")
                            .font(.title2)
                            .padding(.bottom, 5)
                        Text("This number is intended to reflect roughly how well the day was from your perspective. Future versions will allow you customize the factors that go into calculating this number.")
                            .padding(.bottom, 10)
                    }

                    Spacer()
                }

                HStack {
                    VStack {
                        Text(String(score))
                            .font(.largeTitle)
                    }

                    VStack {
                        ForEach(nav.score.rules) { rule in
                            Text(rule.description)
                        }
                    }
                }
            }
            .padding()
            .background(Theme.headerColour)
            .onAppear(perform: actionOnAppear)
        }
    }
}

extension Planning.Summary {
    init() {
        _records = CoreDataRecords.fetchForDate(Date())
    }

    private func actionOnAppear() -> Void {
        calculateScore()
        score = nav.score.value
    }

    private func calculateScore() -> Void {
//        nav.score.rules = [
//            Navigation.Score.Rule(description: "+ 1: More than 1 job", action: .increment, condition: {nav.planning.jobs.count > 0}())
//        ]
//        nav.score.book

        nav.score.calculate()
    }
}
