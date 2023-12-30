//
//  PostingInterface.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-25.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

extension Today {
    struct PostingInterface: View {
        @State private var text: String = ""

        @FocusState private var primaryTextFieldInFocus: Bool

        @Environment(\.managedObjectContext) var moc
        @EnvironmentObject public var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    FancyTextField(
                        placeholder: "What are you working on?",
                        lineLimit: 11,
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
                        HStack(spacing: 5) {
                            Spacer()
                            FancyButtonv2(
                                text: "Reset interface to default state",
                                action: clearAction,
                                icon: "arrow.clockwise",
                                fgColour: nav.session.job != nil ? Color.fromStored(nav.session.job!.colour!).isBright() ? .black : .white : .white,
                                showLabel: false,
                                size: .tiny,
                                type: .clear
                            )
                            .help("Reset interface to default state")
                            .frame(width: 30, height: 30)
                            .background(nav.session.job != nil ? nav.session.job!.colour_from_stored() : Theme.toolbarColour)
                            .disabled(nav.session.job == nil)

                            FancyButtonv2(
                                text: nav.session.job != nil ? "Log to job \(nav.session.job!.jid.string)" : "Log",
                                action: submitAction,
                                icon: "plus",
                                fgColour: nav.session.job != nil ? Color.fromStored(nav.session.job!.colour!).isBright() ? .black : .white : .white,
                                showLabel: false,
                                size: .tiny,
                                type: .clear
                            )
                            .help("Create a new record (alternatively, press Return!)")
                            .frame(width: 30, height: 30)
                            .background(nav.session.job != nil ? nav.session.job!.colour_from_stored() : Theme.toolbarColour)
                            .disabled(nav.session.job == nil)
                        }
                    }
                }
                .frame(height: 215)

                FancyHelpText(text: "Choose a job from the sidebar, then type into the field above and hit enter (or click the + icon at the bottom-right) to create a new record in the table below.")
            }
            .onChange(of: text) { newText in
                if newText.isEmpty {
                    nav.save()
//                    nav.state.on(.ready, { _ in
//                        nav.save()
//                    })
//                    let _ = nav.state.advance()
//                    nav.save()
                }
            }
        }
    }
}

extension Today.PostingInterface {
    private func submitAction() -> Void {
        if !text.isEmpty && nav.session.job != nil {
            Task {
                await self.save()
            }
        } else {
            print("[error] Message, job ID OR task URL are required to submit")
        }
    }

    private func save() async -> Void {
        if let job = nav.session.job {
            let record = LogRecord(context: moc)
            record.timestamp = Date()
            record.message = text
            record.alive = true
            record.id = UUID()
            record.job = job
            
            do {
                try record.validateForInsert()

                PersistenceController.shared.save()
                text = ""
                nav.session.idate = DateHelper.identifiedDate(for: Date(), moc: moc)
            } catch {
                print("[error] Save error \(error)")
            }
        }
    }

    private func clearAction() -> Void {
        text = ""
        nav.session.job = nil
    }
}
