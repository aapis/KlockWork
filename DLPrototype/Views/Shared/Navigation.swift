//
//  Navigation.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-28.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

public enum Page {
    case dashboard, today, notes, tasks, projects, jobs, companies

    var ViewUpdaterKey: String {
        switch self {
        case .dashboard:
            return "dashboard"
        case .today:
            return "today.dashboard"
        case .tasks:
            return "task.dashboard"
        case .notes:
            return "note.dashboard"
        case .projects:
            return "project.dashboard"
        case .jobs:
            return "job.dashboard"
        case .companies:
            return "companies.dashboard"
        }
    }

    var colour: Color {
        switch self {
        case .dashboard:
            return .blue
        case .today:
            return .blue
        case .tasks:
            return .blue
        case .notes:
            return .blue
        case .projects:
            return .blue
        case .jobs:
            return .blue
        case .companies:
            return .blue
        }
    }

    var defaultTitle: String {
        switch self {
        case .dashboard:
            return "Dashboard"
        case .today:
            return "Today"
        case .tasks:
            return "Tasks"
        case .notes:
            return "Notes"
        case .projects:
            return "Projects"
        case .jobs:
            return "Jobs"
        case .companies:
            return "Companies"
        }
    }
}

public enum PageGroup: Hashable {
    case views, entities
}

public class Navigation: Identifiable, ObservableObject {
    public var id: UUID = UUID()

    @Published public var view: AnyView? = AnyView(Dashboard())
    @Published public var parent: Page? = .dashboard
    @Published public var sidebar: AnyView? = AnyView(DashboardSidebar())
    @Published public var title: String = ""
    @Published public var pageId: UUID? = UUID()

    public func pageTitle() -> String {
        if title.isEmpty {

            return parent?.defaultTitle ?? ""
        }

        return title + " - " + parent!.defaultTitle
    }
}
