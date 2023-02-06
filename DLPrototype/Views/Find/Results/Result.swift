//
//  Result.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-02-04.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI

// NOPE
// the problem with this general approach is that 'id' is an existing field on LogRecord/other NSManagedObjects, so trying to make it Identifiable will always fail
// solution.. ??
//extension LogRecord: Identifiable {
//    public typealias ID = Int
//    public var lid: Int {
//        return hash
//    }
//}

struct Result<T: RandomAccessCollection>: View {
    public var bucket: T
    @Binding public var text: String
    
    @State private var entities: [T.Element] = []
    
    var body: some View {
        GridRow {
            ZStack {
                Theme.toolbarColour
                
                Text("matching \(bucket.count)")
                
//                if bucket.count > 0 {
////                    ForEach(entities) { item in
//                    List(entities, id: \.lid) { item in
//                        Text("\(item.job.jid.string)")
//                    }
//                }
            }
        }
        .frame(maxWidth: 300, maxHeight: 300)
        .onAppear(perform: onAppear)
    }
    
    private func onAppear() -> Void {
//        bArr = bucket.enumerated()
        entities = []
        for i in bucket {
//            print("FERPSTART \(i)")
            entities.append(i)
        }
        print("FERPSTART entities \(entities)")
        print("FERPSTART")
        print("FERPSTART bucket \(bucket.count)")
    }
}
