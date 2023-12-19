//
//  SearchLanguageParser.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-18.
//  Copyright © 2023 YegCollective. All rights reserved.
//

public struct SearchLanguage {}

extension SearchLanguage {
    public struct Species {
        var name: String
    }
    
    public struct Column {
        
    }
    
    public struct Value {
        
    }
    
    public class Parser {
        private var with: String
        
        init(with: String) {
            self.with = with
        }
        
        //@job.id=412
        public func types() -> [Species] {
            let pattern = /^@(.*?)\./
            var types: [Species] = []
            
            if let match = with.firstMatch(of: pattern) {
                print("DERPO match=\(match)")
            }
            
            return types
        }
    }
}
