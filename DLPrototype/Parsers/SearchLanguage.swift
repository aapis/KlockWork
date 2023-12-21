//
//  SearchLanguageParser.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-18.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

public struct SearchLanguage {}

extension SearchLanguage {
    public struct Results {
        var components: Set<SearchLanguage.Component> = []
        var moc: NSManagedObjectContext

        init(components: Set<SearchLanguage.Component>, moc: NSManagedObjectContext) {
            self.components = components
            self.moc = moc
        }
        
        func find() -> [String: [NSManagedObject]] {
            var data: [String: [NSManagedObject]] = [:]
            var jobs: [Job] = []

            for component in components {
                switch component.species.name {
                case "Job":
                    if let match = job(id: component.value) {
                        jobs.append(match)
                    }
                default:
                    print("DERPO unknown species \(component.species.name)")
                }
                
                data["Jobs"] = jobs
            }

//            for (group, results) in data {
//                switch group {
//                case "Jobs":
//                    for result in results as! [Job] {
//                        print("DERPO result.jid=\(result.jid.string)")
//                    }
//                default:
//                    print("DERPO unknown")
//                }
//            }

            return data
        }

        private func job(id: SearchLanguage.Component.Value) -> Job? {
            if let int = id.int {
                if let species = CoreDataJob(moc: moc).byId(Double(int)) {
                    return species
                }
            }

            return nil
        }
    }

    public class Parser {
        public var components: Set<SearchLanguage.Component> = []

        private let pattern = /^@(.*?)\.(.*?)=(\d+)/
        private var with: String

        init(with: String) {
            self.with = with
        }
        
        //@job.id=412
        public func parse() -> Self {
            let matches = with.matches(of: pattern)

            for match in matches {
                let component = Component(
                    species: Component.Species(name: String(match.1).capitalized),
                    column: Component.Column(name: String(match.2)),
                    command: Component.Command.equals,
                    value: Component.Value(int: Int(match.3)!)
                )

                if component.isValid {
                    components.insert(component)
                }
            }

            return self
        }
    }
}

extension SearchLanguage {
    public struct Component: Hashable, Equatable {
        var id: UUID = UUID()
        var species: Species
        var column: Column
        var command: Command
        var value: Value
        var isValid: Bool = false
    }
}

extension SearchLanguage.Component {
    public struct Species {
        var name: String
    }

    public struct Column {
        var name: String
    }
    
    public enum Command {
        case equals, add, sub, mult, div
        
        var symbol: String {
            switch self {
            case .equals:
                return "="
            case .add:
                return "+"
            case .sub:
                return "-"
            case .mult:
                return "x"
            case .div:
                return "/"
            }
        }
    }

    public struct Value {
        var int: Int? = 0
    }
}

extension SearchLanguage.Component {
    init(species: Species, column: Column, command: Command, value: Value) {
        self.species = species
        self.column = column
        self.command = command
        self.value = value
        
        if !self.species.name.isEmpty && !self.column.name.isEmpty && self.value.int != nil {
            self.isValid = true
        }
    }

    static public func == (lhs: SearchLanguage.Component, rhs: SearchLanguage.Component) -> Bool {
        return lhs.species.name == rhs.species.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(species.name)
    }
}
