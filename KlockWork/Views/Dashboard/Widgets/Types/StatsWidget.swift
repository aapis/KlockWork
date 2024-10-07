//
//  StatsWidget.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import KWCore

struct StatsWidget: View {
    @Binding public var wordCount: Int
    @Binding public var jobCount: Int
    @Binding public var recordCount: Int
    
    var body: some View {
        VStack {
            HStack {
                Text("Word count")
                Spacer()
                Text(String(wordCount))
            }
            
            HStack {
                Text("Job count")
                Spacer()
                Text(String(jobCount))
            }
            
            HStack {
                Text("Record count")
                Spacer()
                Text(String(recordCount))
            }
        }
        .padding([.leading, .trailing])
    }
}
