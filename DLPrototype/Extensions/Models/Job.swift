//
//  Job.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-08-30.
//  Copyright © 2023 YegCollective. All rights reserved.
//

extension Job {
    func id_int() -> Int {
        return Int(exactly: jid.rounded(.toNearestOrEven)) ?? 0
    }
}
