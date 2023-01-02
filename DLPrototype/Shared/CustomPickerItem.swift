//
//  CustomPickerItem.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-01-02.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation

struct CustomPickerItem: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var tag: Int
    var disabled: Bool = false
}
