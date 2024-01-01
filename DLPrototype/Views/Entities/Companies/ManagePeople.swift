//
//  ManagePeople.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-12-15.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct ManagePeople: View {
    public var company: Company

    private var columns: [GridItem] {
        Array(repeating: .init(.flexible(minimum: 100)), count: 2)
    }

    var body: some View {
        VStack(alignment: .leading) {
            About()
            
            LazyVGrid(columns: columns, alignment: .leading) {
                VStack(alignment: .leading, spacing: 20) {
                    FancySubTitle(text: "Associated people", image: "checkmark")
                    Divider()
                    PeopleList(company: company)
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 20) {
                    FancySubTitle(text: "Add a new person", image: "plus")
                    Divider()
                    AddPerson(company: company)
                    Spacer()
                }
            }

            Spacer()
        }
    }
}

extension ManagePeople {
    struct About: View {
        private let copy: String = "Add people who work for this company. You can refer to them later using @company.personName syntax to connect people to discussions and actions."

        var body: some View {
            VStack {
                HStack {
                    Text(copy).padding(15)
                    Spacer()
                }
            }
            .background(Theme.cOrange)
            FancyDivider()
        }
    }

    struct AddPerson: View {
        public var company: Company

        @State private var name: String = ""
        @State private var title: String = ""

        @Environment(\.managedObjectContext) var moc

        var body: some View {
            VStack(alignment: .leading) {
                FancyTextField(placeholder: "Name", showLabel: true, text: $name)
                FancyTextField(placeholder: "Job title", onSubmit: actionAddPerson, showLabel: true, text: $title)

                HStack {
                    Spacer()
                    FancyButtonv2(text: "Add", action: actionAddPerson, icon: "plus")
                }
            }
        }
    }

    struct PeopleList: View {
        public var company: Company

        @FetchRequest private var people: FetchedResults<Person>

        @Environment(\.managedObjectContext) var moc

        var body: some View {
            VStack(spacing: 1) {
                ForEach(people) { person in
                    Grid(alignment: .leading, horizontalSpacing: 1, verticalSpacing: 1) {
                        GridRow {
                            HStack {
                                FancyButton(text: "Delete person", action: {self.delete(person)}, icon: "multiply", transparent: true, showLabel: false)
                                Text(person.name!)
                                Spacer()
                                Text(person.title!)
                            }
                            .padding([.trailing], 10)
                        }
                        .background(Theme.rowColour)
                    }
                }
            }
        }
    }
}

extension ManagePeople.PeopleList {
    init(company: Company) {
        self.company = company

        let pRequest: NSFetchRequest<Person> = Person.fetchRequest()
        pRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Person.title?, ascending: true),
        ]
        pRequest.predicate = NSPredicate(format: "company = %@", company)

        _people = FetchRequest(fetchRequest: pRequest, animation: .easeInOut)
    }

    private func delete(_ person: Person) -> Void {
        moc.delete(person)
        PersistenceController.shared.save()
    }
}

extension ManagePeople.AddPerson {
    private func actionAddPerson() -> Void {
        let person = Person(context: moc)
        person.name = name
        person.title = title
        person.created = Date()
        person.lastUpdate = Date()
        person.company = company
        person.id = UUID()

        PersistenceController.shared.save()

        name = ""
        title = ""
    }
}
