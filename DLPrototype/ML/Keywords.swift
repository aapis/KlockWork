//
//  Keywords.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-04-24.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import CreateML

class Keywords {
    public init(from: Dictionary<String, Array<String>>) {
        
    }
    
    public init(from: Dictionary<String, MLDataValueConvertible>) {
//        do {
//            let data = try MLDataTable(dictionary: from)
//            let (trainingData, testingData) = data.randomSplit(by: 0.8, seed: 5)
//            let wordTagger = MLWordTagger(trainingData: [trainingData["tokens"], trainingData["labels"]])
//            print("DERPO \(wordTagger.description)")
//        } catch {
//            print("[error] ML.Keywords Unable to parse dictionary")
//        }
    }
    
    public init(from: URL) {
        do {
            let data = try MLDataTable(contentsOf: from)
            
            let (trainingData, testingData) = data.randomSplit(by: 0.8, seed: 5)
//            print("DERPO \(trainingData)")

            let wordTagger = try MLWordTagger(trainingData: trainingData,
                                         tokenColumn: "tokens",
                                         labelColumn: "labels")
            
            let evaluationMetrics = wordTagger.evaluation(on: testingData,
                                                          tokenColumn: "tokens",
                                                          labelColumn: "labels")
            
            print("DERPO \(evaluationMetrics)")
        } catch {
            print("[error] ML.Keywords Unable to parse dictionary")
            print("[error] \(error)")
        }
    }
}
