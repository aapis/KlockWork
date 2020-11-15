//
//  Log.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-10.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import SwiftUI

struct Backup: View {
    var category: Category
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Image(systemName: "cloud.fill"))
                    .font(.title)
                Text("Backup \(category.title).log")
                    .font(.title)
            }
            
            Divider()
            
            Text("Last Backup: ") + Text(self.getLastBackupDate())
            
            Button("Backup Now", action: {
                self.performBackup()
            })
                .background(Color.accentColor)
            
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    func getLastBackupDate() -> String {
        let log = getDocumentsDirectory().appendingPathComponent("\(category.title).log")
        
        if let logLines = try? String(contentsOf: log) {
            let lines = logLines.components(separatedBy: .newlines)
            
            if lines.count > 0 {
                return lines.first!
            }
        }
        
        return "N/A"
    }
    
    func performBackup() -> Void {
        let today = Date()
        
        
    }
}
