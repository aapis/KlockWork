//
//  PageConfiguration.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-30.
//  Copyright © 2024 YegCollective. All rights reserved.
//


import SwiftUI
import KWCore

struct PageConfiguration {
    let entityType: EntityType
    let planType: PlanType

    var description: String {
        return "Entity"
    }
}

extension PageConfiguration {
    enum PlanType: CaseIterable, Equatable {
        case daily, feature, upcoming, overdue

        /// Interface-friendly representation
        var label: String {
            switch self {
            case .daily: "Daily"
            case .feature: "Feature"
            case .upcoming: "Upcoming"
            case .overdue: "Overdue"
            }
        }

        // @TODO: localize somehow?
        var enSingular: String {
            switch self {
            case .daily: "Day"
            case .feature: "Feature"
            case .upcoming: "Upcoming"
            case .overdue: "Overdue"
            }
        }

        /// Associated icon
        var icon: Image {
            switch self {
            case .daily: Image(systemName: "calendar")
            case .feature: Image(systemName: "list.bullet.below.rectangle")
            case .upcoming: Image(systemName: "hourglass")
            case .overdue: Image(systemName: "alarm")
            }
        }

        /// Alternative icon to use when selected
        var selectedIcon: Image {
            switch self {
            case .daily: Image(systemName: "calendar")
            case .feature: Image(systemName: "list.bullet.below.rectangle")
            case .upcoming: Image(systemName: "hourglass.bottomhalf.filled")
            case .overdue: Image(systemName: "alarm.fill")
            }
        }
    }

    enum EntityType: CaseIterable, Equatable {
        case records, tasks, notes, people, companies, projects, jobs, terms, definitions, plans, BruceWillis

        /// Interface-friendly representation
        var label: String {
            switch self {
            case .records: "Records"
            case .jobs: "Jobs"
            case .tasks: "Tasks"
            case .notes: "Notes"
            case .companies: "Companies"
            case .people: "People"
            case .projects: "Projects"
            case .terms: "Terms"
            case .definitions: "Definitions"
            case .plans: "Plans"
            default: ""
            }
        }

        // @TODO: localize somehow?
        var enSingular: String {
            switch self {
            case .records: "Record"
            case .jobs: "Job"
            case .tasks: "Task"
            case .notes: "Note"
            case .companies: "Company"
            case .people: "Person"
            case .projects: "Project"
            case .terms: "Term"
            case .definitions: "Definition"
            case .plans: "Plan"
            default: ""
            }
        }

        /// Associated icon
        var icon: Image {
            switch self {
            case .records: Image(systemName: "tray")
            case .jobs: Image(systemName: "hammer")
            case .tasks: Image(systemName: "checklist")
            case .notes: Image(systemName: "note.text")
            case .companies: Image(systemName: "building.2")
            case .people: Image(systemName: "person.2")
            case .projects: Image(systemName: "folder")
            case .terms: Image(systemName: "list.bullet.rectangle")
            case .definitions: Image(systemName: "list.dash.header.rectangle")
            case .plans: Image(systemName: "hexagon")
            default: Image(systemName: "house")
            }
        }

        /// Alternative icon to use when selected
        var selectedIcon: Image {
            switch self {
            case .records: Image(systemName: "tray.fill")
            case .jobs: Image(systemName: "hammer.fill")
            case .tasks: Image(systemName: "checklist")
            case .notes: Image(systemName: "note.text")
            case .companies: Image(systemName: "building.2.fill")
            case .people: Image(systemName: "person.2.fill")
            case .projects: Image(systemName: "folder.fill")
            case .terms: Image(systemName: "list.bullet.rectangle.fill")
            case .definitions: Image(systemName: "list.dash.header.rectangle")
            case .plans: Image(systemName: "hexagon.fill")
            default: Image(systemName: "house.fill")
            }
        }

        var filters: [FilterField] {
            switch self {
            case .records: return [FilterField(name: "Published")]
            case .jobs: return [FilterField(name: "Published")]
            case .tasks: return [FilterField(name: "Published")]
            case .notes: return [FilterField(name: "Published")]
            case .companies: return [FilterField(name: "Published")]
            case .people: return [FilterField(name: "Published")]
            case .projects: return [FilterField(name: "Published")]
            case .terms: return [FilterField(name: "Published")]
            case .definitions: return [FilterField(name: "Published")]
            case .plans: return [FilterField(name: "Published")]
            default: return [FilterField(name: "Published")]
            }
        }

        var page: Page {
            switch self {
            case .records: return .today
            case .jobs: return .jobs
            case .tasks: return .tasks
            case .notes: return .notes
            case .companies: return .companies
            case .people: return .people
            case .projects: return .projects
            case .terms: return .terms
            case .definitions: return .terms
            default: return .dashboard
            }
        }
    }
    
    enum AppPage: CaseIterable, Equatable {
        case planning, today, explore, find, create, modify, error, intersitial, settings

        var primaryColour: Color {
            switch self {
            case .planning: Theme.cOrange
            case .today, .create, .modify: Theme.cPurple
            case .find: Theme.cRoyal
            case .error, .intersitial, .settings: .white
            default:
                Theme.cGreen
            }
        }

        var buttonBackgroundColour: Color {
            switch self {
            default:
                Theme.cGreen
            }
        }
    }

    struct EntityTypePair {
        var key: EntityType
        var value: Int
    }
}
