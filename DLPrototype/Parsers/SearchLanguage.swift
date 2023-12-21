//
//  SearchLanguageParser.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-18.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

// MARK: Structs
public struct SearchLanguage {}

extension SearchLanguage {
    public struct Results {
        var components: Set<SearchLanguage.Component> = []
        var moc: NSManagedObjectContext
    }
    
    public struct Component: Hashable, Equatable {
        var id: UUID = UUID()
        var species: Species
        var column: Column
        var command: Command
        var value: Value
        var isValid: Bool = false
    }

    public class Parser {
        var components: Set<SearchLanguage.Component> = []
        var with: String = ""
        private let pattern = /^@(.*?)\.(.*?)=(\d+)/
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

extension SearchLanguage.Results {
    public enum SpeciesType {
        case job, task, record, company, person, project
    }
}

// MARK: Method definitions
extension SearchLanguage.Parser {
    convenience init(with: String) {
        self.init()
        self.with = with
    }
    
    //@job.id=412
    public func parse() -> Self {
        let matches = with.matches(of: pattern)

        for match in matches {
            let component = SearchLanguage.Component(
                species: SearchLanguage.Component.Species(name: String(match.1).capitalized),
                column: SearchLanguage.Component.Column(name: String(match.2)),
                command: SearchLanguage.Component.Command.equals,
                value: SearchLanguage.Component.Value(int: Int(match.3)!)
            )

            if component.isValid {
                components.insert(component)
            }
        }

        return self
    }
}

extension SearchLanguage.Results {
    func find() -> [SpeciesType: [NSManagedObject]] {
        var data: [SpeciesType: [NSManagedObject]] = [:]
        var jobs: [Job] = []
        var tasks: [LogTask] = []
        var projects: [Project] = []
        var companies: [Company] = []

        for component in components {
            switch component.species.name {
            case "Job":
                if let match = job(id: component.value) {
                    jobs.append(match)
                    
                    tasks = match.tasks?.allObjects as! [LogTask]

                    if let project = match.project {
                        projects.append(project)
                        
                        if let company = project.company {
                            companies.append(company)
                        }
                    }
                }
            default:
                print("DERPO unknown species \(component.species.name)")
            }
            
            data[.job] = jobs
            data[.task] = tasks
            data[.project] = projects
            data[.company] = companies
        }

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
