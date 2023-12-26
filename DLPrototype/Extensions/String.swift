//
//  String.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-25.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation

extension String {
    func ints() -> String {
        return self.filter { "0123456789".contains($0) }
    }
}
