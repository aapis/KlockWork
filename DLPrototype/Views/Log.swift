//
//  Log.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2020-07-10.
//  Copyright © 2020 YegCollective. All rights reserved.
//

import SwiftUI

struct Log: View {
    var category: Category
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Image(systemName: "doc.fill"))
                    .font(.title)
                Text("\(category.title).log")
                    .font(.title)
            }
            
            Divider()
            
            ScrollView {
                Text(readFile())
            }
            
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    func readFile() -> String {
        var lines: String = "nothing to see here"

        let log = getDocumentsDirectory().appendingPathComponent("\(category.title).log")
            
        if let logLines = try? String(contentsOf: log) {
            if !logLines.isEmpty {
                lines = logLines
            }
        }
        
        return lines
    }
}
