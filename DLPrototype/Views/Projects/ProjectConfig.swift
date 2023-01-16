//
//  ProjectConfiguration.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-14.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct ProjectConfig: View {
    public var project: Project
    
    @State private var bannedWords: [BannedWord] = []
    @State private var bannedWord: String = ""
    @State private var ignoredJobs: [Job] = []
    @State private var savedJobs: [Job] = []
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject public var updater: ViewUpdater
    
    // MARK: body view
    var body: some View {
        VStack(alignment: .leading) {
            FancySubTitle(text: "Banned words", image: "text.redaction")
            FancyTextField(placeholder: "Add a banned word", lineLimit: 1, onSubmit: createBannedWord, text: $bannedWord)
            
            HStack {
                ForEach(bannedWords) { bad in
                    Button(action: {removeFromBannedWordList(bad)}) {
                        HStack {
                            Image(systemName: "multiply")
                            Text(bad.word!)
                        }
                    }
                    .buttonStyle(.borderless)
                    .padding(5)
                    .background(.black.opacity(0.2))
                }
            }
            
            FancyDivider()
            
            HStack(spacing: 5) {
                Grid(alignment: .leading, horizontalSpacing: 1, verticalSpacing: 1) {
                    GridRow {
                        FancySubTitle(text: "Ignored Jobs", image: "nosign")
                    }
                    
                    ignoredJobsView
                }
                
                Grid(alignment: .leading, horizontalSpacing: 1, verticalSpacing: 1) {
                    GridRow {
                        FancySubTitle(text: "Ignore-able jobs", image: "plus")
                    }
                    
                    currentlyAssignedJobsView
                }
            }
        }
        .onAppear(perform: onAppear)
    }
    
    // MARK: ignoredJobsView
    @ViewBuilder var ignoredJobsView: some View {
        GridRow {
            Group {
                ZStack {
                    Theme.headerColour
                }

            }
            .frame(width: 80)

            Group {
                ZStack(alignment: .leading) {
                    Theme.headerColour
                    Text("JID")
                        .padding(5)
                }
            }
            Group {
                ZStack {
                    Theme.headerColour
                    Text("Colour")
                        .padding(5)
                }
            }
        }
        .frame(height: 40)
        
        ScrollView {
            ForEach(ignoredJobs, id: \.jid) { job in
                HStack(spacing: 1) {
                    GridRow {
                        Group {
                            ZStack {
                                Theme.rowColour
                                FancyButton(text: "Remove job from ignore list", action: {deSelectJob(job)}, icon: "multiply", transparent: true, showLabel: false)
                            }
                        }
                        .frame(width: 80)
                        
                        Group {
                            ZStack(alignment: .leading) {
                                Theme.rowColour
                                Text(job.jid.string)
                                    .padding(5)
                            }
                        }
                        
                        Group {
                            ZStack {
                                let colour = Color.fromStored(job.colour ?? Theme.rowColourAsDouble)
                                colour
                                Text(colour.description.debugDescription)
                                    .padding(5)
                                    .foregroundColor(colour.isBright() ? Color.black : Color.white)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: currentlyAssignedJobsView
    @ViewBuilder var currentlyAssignedJobsView: some View {
        GridRow {
            Group {
                ZStack {
                    Theme.headerColour
                }

            }
            .frame(width: 80)

            Group {
                ZStack(alignment: .leading) {
                    Theme.headerColour
                    Text("JID")
                        .padding(5)
                }
            }
            Group {
                ZStack {
                    Theme.headerColour
                    Text("Colour")
                        .padding(5)
                }
            }
        }
        .frame(height: 40)
        
        ScrollView {
            ForEach(savedJobs, id: \.jid) { job in
                HStack(spacing: 1) {
                    GridRow {
                        Group {
                            ZStack {
                                Theme.rowColour
                                FancyButton(text: "Ignore job", action: {selectJob(job)}, icon: "nosign", transparent: true, showLabel: false)
                            }
                        }
                        .frame(width: 80)
                        
                        Group {
                            ZStack(alignment: .leading) {
                                Theme.rowColour
                                Text(job.jid.string)
                                    .padding(5)
                            }
                        }
                        
                        Group {
                            ZStack {
                                let colour = Color.fromStored(job.colour ?? Theme.rowColourAsDouble)
                                colour
                                Text(colour.description.debugDescription)
                                    .padding(5)
                                    .foregroundColor(colour.isBright() ? Color.black : Color.white)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func onAppear() -> Void {
        if let bw = project.configuration?.bannedWords! {
            let savedBws = bw.allObjects as! [BannedWord]
            bannedWords = savedBws
        }
        
        if let savedJerbs = project.jobs {
            savedJobs = savedJerbs.allObjects as! [Job]
        }
    }
    
    private func removeFromBannedWordList(_ word: BannedWord) -> Void {
        bannedWords.removeAll(where: ({$0 == word}))
    }
    
    private func createBannedWord() -> Void {
        let matches = CoreDataProjectConfiguration(moc: moc).byWord(bannedWord)
        
        if matches.count == 0 {
            let bword = BannedWord(context: moc)
            bword.word = bannedWord
            bword.created = Date()
            bword.id = UUID()
            
            bannedWords.append(bword)
        } else {
            let bad = matches.first!
            
            if !bannedWords.contains(where: ({$0.word == bad.word})) {
                bannedWords.append(matches.first!)
            }
        }
        
        for word in bannedWords {
            project.configuration?.addToBannedWords(word)
        }
        
        bannedWord = ""
        
        PersistenceController.shared.save()
    }
    
    private func selectJob(_ job: Job) -> Void {
        ignoredJobs.append(job)
        savedJobs.removeAll(where: ({$0 == job}))
    }
    
    private func deSelectJob(_ job: Job) -> Void {
        ignoredJobs.removeAll(where: ({$0 == job}))
        savedJobs.append(job)
    }
}
