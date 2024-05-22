//
//  CustomPickerItem.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

public struct CustomPickerItem: Identifiable, Hashable {
    public static func == (lhs: CustomPickerItem, rhs: CustomPickerItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    public var id = UUID()
    public var title: String
    public var tag: Int
    public var disabled: Bool = false
    public var project: Project? = nil

    static public func listFrom(_ records: [String]) -> [CustomPickerItem] {
        var list: [CustomPickerItem] = []
        
        for (i, rec) in records.enumerated() {
            list.append(CustomPickerItem(title: rec, tag: i))
        }
        
        return list
    }
}
