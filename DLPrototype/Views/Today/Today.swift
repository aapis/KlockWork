//
//  Add.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-10.
//  Copyright © 2020 YegCollective. All rights reserved.
//
import SwiftUI

struct Today: View {
    public var defaultSelectedDate: Date? = nil

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var nav: Navigation
    @EnvironmentObject public var ce: CoreDataCalendarEvent

    @FocusState private var primaryTextFieldInFocus: Bool
    
    // MARK: body view
    var body: some View {
        VStack(alignment: .leading) {
            PostingInterface(date: defaultSelectedDate)
            LogTableRedux(date: defaultSelectedDate)
                .environmentObject(ce)
                .environmentObject(nav)
        }
        .padding()
        .background(Theme.toolbarColour)
    }
}

extension Today {
    struct PostingInterface: View {
        public var date: Date? = nil

        @State private var text: String = ""

        @FocusState private var primaryTextFieldInFocus: Bool

        @Environment(\.managedObjectContext) var moc
        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading) {
                ZStack(alignment: .topLeading) {
                    FancyTextField(
                        placeholder: "What are you working on?",
                        lineLimit: 6,
                        onSubmit: submitAction,
                        fgColour: nav.session.job != nil ? nav.session.job!.colour_from_stored().isBright() ? .black : .white : .white,
                        text: $text
                    )
                    .background(nav.session.job != nil ? nav.session.job!.colour_from_stored() : .clear)
                    .focused($primaryTextFieldInFocus)
                    .onAppear {
                        // thx https://www.kodeco.com/31569019-focus-management-in-swiftui-getting-started#toc-anchor-002
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                            self.primaryTextFieldInFocus = true
                        }
                    }

                    VStack(alignment: .trailing) {
                        Spacer()
                        HStack {
                            Spacer()
                            FancyButtonv2(
                                text: nav.session.job != nil ? "Log to job \(nav.session.job!.jid.string)" : "Log",
                                action: submitAction,
                                icon: "plus",
                                fgColour: nav.session.job != nil ? Color.fromStored(nav.session.job!.colour!).isBright() ? .black : .white : .white,
                                showLabel: false,
                                size: .tiny,
                                type: .clear
                            )
                            .frame(width: 30, height: 30)
                            .background(nav.session.job != nil ? nav.session.job!.colour_from_stored() : Theme.toolbarColour)
                            .disabled(nav.session.job == nil)
                        }
                    }
                }
                .frame(height: 130)

                FancyHelpText(text: "Choose a job from the sidebar, then type into the field above and hit enter (or click the + icon at the bottom-right) to create a new record in the table below.")
            }
        }
    }
}

extension Today.PostingInterface {
    private func submitAction() -> Void {
        if !text.isEmpty && nav.session.job != nil {
        
            let record = LogRecord(context: moc)
            record.timestamp = Date()
            record.message = text
            record.alive = true
            record.id = UUID()
            record.job = nav.session.job

            nav.session.idate = DateHelper.identifiedDate(for: record.timestamp!, moc: moc)
            text = ""
            PersistenceController.shared.save()
        } else {
            print("[error] Message, job ID OR task URL are required to submit")
        }
    }
}
