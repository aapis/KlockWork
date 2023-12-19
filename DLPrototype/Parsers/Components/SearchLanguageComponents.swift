//
//  SearchLanguageComponents.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-18.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation

extension SearchLanguage {
    struct Components {
        var types: [Species] = []
        var columns: [Column] = []
        var values: [Value] = []
        
        //    mutating func parse(_ raw: String) -> Self {
        //        let parser = SearchLanguageParser(with: raw)
        //        types = parser.types()
        //        
        //        
        //        return self
        //    }
    }
}
