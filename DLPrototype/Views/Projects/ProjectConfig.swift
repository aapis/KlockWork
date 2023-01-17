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
    
    static private var exportFormatPickerItems: [CustomPickerItem] = [
        CustomPickerItem(title: "Choose an export format", tag: 0),
        CustomPickerItem(title: "Standard", tag: 1)
    ]
    
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
            FancySubTitle(text: "Export format", image: "arrow.down.to.line")
            FancyPicker(onChange: change, items: ProjectConfig.exportFormatPickerItems)
            
            Spacer()
        }
        .onAppear(perform: onAppear)
        .id(updater.ids["pc.form"])
    }
    
    private func onAppear() -> Void {
        if let bw = project.configuration?.bannedWords! {
            let savedBws = bw.allObjects as! [BannedWord]
            bannedWords = savedBws
        }
    }
    
    private func change(selected: Int, sender: String?) -> Void {
        
    }
    
    private func removeFromBannedWordList(_ word: BannedWord) -> Void {
        bannedWords.removeAll(where: ({$0 == word}))
        
        for word in bannedWords {
            project.configuration?.addToBannedWords(word)
        }
        
        project.lastUpdate = Date()
        
        PersistenceController.shared.save()
        updater.update()
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
        
        project.lastUpdate = Date()
        
        bannedWord = ""
        
        PersistenceController.shared.save()
    }
}
