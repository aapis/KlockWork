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
        public var types: [SearchLanguage.Species] = []
        public var columns: [SearchLanguage.Column] = []
        public var values: [SearchLanguage.Value] = []
        
        //    mutating func parse(_ raw: String) -> Self {
        //        let parser = SearchLanguageParser(with: raw)
        //        types = parser.types()
        //        
        //        
        //        return self
        //    }
    }
}
