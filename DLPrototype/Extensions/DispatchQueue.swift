//
//  DispatchQueue.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-19.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static func background(delay: Double = 0.0, background: (()->String?)? = nil, completion: ((String?) -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            let bg = background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion(bg)
                })
            }
        }
    }
}
