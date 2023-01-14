//
//  CustomPickerItem.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation

public struct CustomPickerItem: Identifiable, Hashable {
    public var id = UUID()
    public var title: String
    public var tag: Int
    public var disabled: Bool = false
    
    static public func listFrom(_ records: [String]) -> [CustomPickerItem] {
        var list: [CustomPickerItem] = []
        
        for (i, rec) in records.enumerated() {
            list.append(CustomPickerItem(title: rec, tag: i))
        }
        
        return list
    }
}
