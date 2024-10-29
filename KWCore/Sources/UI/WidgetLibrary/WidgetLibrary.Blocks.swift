//
//  WidgetLibrary.Blocks.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-28.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import KWCore

extension WidgetLibrary.UI {
    public struct Blocks {
        struct Definition: View {
            @EnvironmentObject public var state: Navigation
            public var definition: TaxonomyTermDefinitions
            @State private var isHighlighted: Bool = false

            var body: some View {
                Button {
                    self.state.session.job = self.definition.job
                    self.state.session.project = self.state.session.job?.project
                    self.state.session.company = self.state.session.project?.company
                    self.state.session.definition = self.definition
                    self.state.to(.definitionDetail)
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Text(self.definition.definition ?? "Error: Missing definition")
                        Spacer()
                    }
                    .padding(8)
                    .background(self.definition.job?.backgroundColor ?? Theme.rowColour)
                    .foregroundStyle((self.definition.job?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base : Theme.lightWhite)
                }
                .buttonStyle(.plain)
                .useDefaultHover({ hover in self.isHighlighted = hover})
            }
        }

        struct Icon: View, Identifiable {
            @EnvironmentObject private var state: Navigation
            @AppStorage("widget.navigator.viewModeIndex") private var viewModeIndex: Int = 0
            public var id: UUID = UUID()
            public var type: EType
            public var text: String
            public var colour: Color
            @State private var isHighlighted: Bool = false

            var body: some View {
                VStack(alignment: .center, spacing: 0) {
                    ZStack(alignment: .center) {
                        (self.viewModeIndex == 0 ? Color.gray.opacity(self.isHighlighted ? 1 : 0.7) : self.colour.opacity(self.isHighlighted ? 1 : 0.7))
                        VStack(alignment: .center, spacing: 0) {
                            (self.isHighlighted ? self.type.selectedIcon : self.type.icon)
                                .symbolRenderingMode(.hierarchical)
                                .font(.largeTitle)
//                                .foregroundStyle(self.viewModeIndex == 0 ? self.colour : self.colour.isBright() ? Theme.base : .white)
                                .foregroundStyle(self.viewModeIndex == 0 ? self.colour : .white)
                        }
                        Spacer()
                    }
                    .frame(height: 65)

                    ZStack(alignment: .center) {
                        (self.isHighlighted ? Color.yellow : Theme.textBackground)
                        VStack(alignment: .center, spacing: 0) {
                            Text(self.text)
                                .font(.system(.title3, design: .monospaced))
                                .foregroundStyle(self.isHighlighted ? Theme.base : .gray)
                        }
                        .padding([.leading, .trailing], 4)
                    }
                    .frame(height: 25)
                }
                .frame(width: 65)
                .clipShape(.rect(cornerRadius: 5))
                .useDefaultHover({ hover in self.isHighlighted = hover })
            }
        }

        struct GenericBlock: View {
            @EnvironmentObject public var state: Navigation
            public var item: NSManagedObject
            @State private var bgColour: Color = .clear
            @State private var name: String = ""

            var body: some View {
                Button {
                    self.actionOnTap()
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Text(self.name)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding(8)
                    .background(self.bgColour)
                    .foregroundStyle(self.bgColour.isBright() ? Theme.base : Theme.lightWhite)
                    .clipShape(.rect(cornerRadius: 5))
                    .help(self.name)
                }
                .contextMenu {
                    Button {
                        ClipboardHelper.copy(self.bgColour.description)
                    } label: {
                        Text("Copy colour HEX to clipboard")
                    }
                }
                .buttonStyle(.plain)
                .useDefaultHover({_ in})
                .onAppear(perform: self.actionOnAppear)
            }
        }
    }
}

extension WidgetLibrary.UI.Blocks.GenericBlock {
    /// Onload handler. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let job = self.item as? Job {
            self.bgColour = job.backgroundColor
            self.name = job.title ?? job.jid.string
        } else if let project = self.item as? Project {
            self.bgColour = project.backgroundColor
            self.name = "\(project.name ?? "Error: Invalid project name") (\(project.abbreviation ?? "YYY"))"
        } else if let company = self.item as? Company {
            self.bgColour = company.backgroundColor
            self.name = "\(company.name ?? "Error: Invalid project name") (\(company.abbreviation ?? "XXX"))"
        }
    }

    /// Fires when a block is tapped
    /// - Returns: Void
    private func actionOnTap() -> Void {
        if let job = self.item as? Job {
            self.state.session.job = job
            self.state.session.project = job.project
            self.state.session.company = job.project?.company
            self.state.to(.jobs)
        } else if let project = self.item as? Project {
            self.state.session.project = project
            self.state.session.company = project.company
            self.state.to(.projectDetail)
        } else if let company = self.item as? Company {
            self.state.session.company = company
            self.state.to(.companyDetail)
        }
    }
}
