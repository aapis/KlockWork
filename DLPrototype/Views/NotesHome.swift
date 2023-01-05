//
//  Notes.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct Notes: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.title)]) public var notes: FetchedResults<Notes>
        
    var body: some View {
        VStack {
            HStack {
                // previous notes
                List {
                    
                }
                
                // main body
                VStack {
                    
                }
            }
        }
    }
}

struct NotesPreview: PreviewProvider {
    static var previews: some View {
        Notes()
            .frame(width: 800, height: 800)
    }
}
