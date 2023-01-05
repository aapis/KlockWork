//
//  DetailsRow.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-03.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

struct DetailsRow: View {
    public var key: String
    public var value: String
    public var colour: Color
    
    var body: some View {
        HStack(spacing: 1) {
            ZStack(alignment: .leading) {
                colour
                
                Text(key)
                    .padding(10)
                    .foregroundColor(colour.isBright() ? Color.black : Color.white)
            }.frame(width: 200)
            
            ZStack(alignment: .leading) {
                colour
                
                Text(value)
                    .padding(10)
                    .foregroundColor(colour.isBright() ? Color.black : Color.white)
            }
        }
    }
}

struct DetailsRowPreview: PreviewProvider {
    static var previews: some View {        
        DetailsRow(key: "Unique jobs", value: "22", colour: Color.red)
    }
}
