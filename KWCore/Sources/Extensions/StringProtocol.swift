//
//  StringProtocol.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-28.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

extension StringProtocol {
    // Thanks: https://stackoverflow.com/a/28288340
    public var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    public var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}
