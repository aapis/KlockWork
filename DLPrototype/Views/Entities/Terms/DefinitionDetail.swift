//
//  DefinitionDetail.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-10-01.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct DefinitionDetail: View {
    @EnvironmentObject public var state: Navigation
    public var definition: TaxonomyTermDefinitions?
    private let page: PageConfiguration.AppPage = .explore
    private let eType: PageConfiguration.EntityType = .terms
    @State private var definitionString: String = ""
    @State private var jobIdString: String = ""
    @State private var alive: Bool = true
    @State private var job: Job?
    // @TODO: not sure if I want this here
//    @FocusState private var primaryTextFieldInFocus: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                Title(text: "Definition", image: "list.bullet.rectangle")
                Spacer()
                FancyButtonv2(text: "Cancel", action: self.actionOnCancel, showIcon: false)
                FancyButtonv2(text: "Save", action: self.actionOnSave, showIcon: false)
            }
            .padding(.bottom)

            VStack(alignment: .leading, spacing: 0) {
                JobPickerUsing(onChange: self.actionOnJobChange, jobId: $jobIdString)
                FancyDivider()
                Toggle("Published", isOn: $alive)
                FancyDivider()
                FancyTextField(
                    placeholder: "A statement of the meaning of a word, phrase, or term, as in a dictionary entry.",
                    lineLimit: 11,
                    onSubmit: self.actionOnSave,
                    text: $definitionString
                )
                // @TODO: not sure if I want this here
//                .focused($primaryTextFieldInFocus)
//                .onAppear {
//                    // thx https://www.kodeco.com/31569019-focus-management-in-swiftui-getting-started#toc-anchor-002
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        self.primaryTextFieldInFocus = true
//                    }
//                }
            }

            Spacer()
        }
        .padding()
        .background(self.page.primaryColour)
        .onAppear(perform: self.actionOnAppear)
    }
}

extension DefinitionDetail {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.definitionString = self.definition?.definition ?? ""
        self.jobIdString = self.definition?.job?.jid.string ?? ""
        self.alive = self.definition?.alive ?? true
    }

    /// Callback that fires when cancel button clicked/tapped
    /// - Returns: Void
    private func actionOnCancel() -> Void {
        self.state.to(.terms)
    }

    /// Callback that fires when save button clicked/tapped
    /// - Returns: Void
    private func actionOnSave() -> Void {
        self.definition?.definition = self.definitionString
        self.definition?.alive = self.alive
        self.definition?.job = self.job
        PersistenceController.shared.save()

        self.state.to(.terms)
    }
    
    /// Fires when an item is selected from the job picker
    /// - Parameters:
    ///   - selected: Int
    ///   - sender: String
    /// - Returns: Void
    private func actionOnJobChange(selected: Int, sender: String?) -> Void {
        if let newJob = CoreDataJob(moc: self.state.moc).byId(Double(selected)) {

            self.job = newJob
            self.jobIdString = newJob.jid.string
        }
    }
}
