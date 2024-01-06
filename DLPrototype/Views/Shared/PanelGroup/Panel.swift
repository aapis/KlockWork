//
//  PanelGroup.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-01-04.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

// @TODO: refactor everything
public struct Panel {
    public enum Orientation {
        case horizontal, vertical
    }
    
    public enum Position {
        case first, middle, last
    }
    
    public struct SelectedValueCoordinates {
        var position: Position
        var item: NSManagedObject
    }
    
    public struct RowConfiguration {
        var text: String
        var action: () -> Void
        var entity: NSManagedObject
        var position: Panel.Position
    }
    
    struct Row: View {
        public var config: RowConfiguration
        
        @State private var highlighted: Bool = false
        
        @EnvironmentObject private var nav: Navigation

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                FancySimpleButton(
                    text: config.text,
                    action: fireCallback,
                    labelView: AnyView(
                        HStack {
                            Text(config.text)
                            Spacer()
                            Image(systemName: config.position == .last ? "hammer" : "arrow.right")
                        }
                        .padding(10)
                        .background(nav.forms.jobSelector.selected != nil ? nav.forms.jobSelector.selected!.item == config.entity ? .orange : .clear : .clear)
                        .foregroundStyle(nav.forms.jobSelector.selected != nil ? nav.forms.jobSelector.selected!.item == config.entity ? .black : .white : .white)
                    ),
                    size: .link,
                    type: .clear
                )
            }
        }
    }
}

extension Panel.Row {
    private func fireCallback() -> Void {
        highlighted = true
        nav.forms.jobSelector.selected = Panel.SelectedValueCoordinates(position: config.position, item: config.entity)
        config.action()
    }
}

struct CompanyPanel: View {
    public var position: Panel.Position
    
    @State private var showSearch: Bool = false
    @State private var searchText: String = ""

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(alignment: .top) {
                    Text("Companies").font(.title3)
                    Spacer()
                    FancySimpleButton(
                        text: "Search",
                        action: {showSearch.toggle()},
                        icon: "magnifyingglass",
                        showLabel: false,
                        showIcon: true,
                        type: .clear
                    )
                    FancySimpleButton(
                        text: "Close",
                        action: closePanel,
                        icon: "xmark",
                        showLabel: false,
                        showIcon: true
                    )
                    .disabled(nav.forms.jobSelector.selected == nil)
                    .opacity(nav.forms.jobSelector.selected == nil ? 0.4 : 1)
            }
            .padding(10)
            
            if showSearch {
                SearchBar(text: $searchText)
            }

            if let firstColData = nav.forms.jobSelector.first {
                if position == .first {
                    VStack(alignment: .leading, spacing: 1) {
                        if !firstColData.isEmpty {
                            ForEach(firstColData) { company in
                                Panel.Row(
                                    config: Panel.RowConfiguration(
                                        text: company.name!,
                                        action: {setMiddlePanel(data: company.projects!.allObjects)},
                                        entity: company,
                                        position: position
                                    )
                                )
                            }
                        } else {
                            Text("No companies found")
                                .padding(10)
                        }
                        Spacer()
                    }
                } else if position == .middle {
                    VStack(alignment: .leading, spacing: 1) {
                        if !nav.forms.jobSelector.middle.isEmpty {
                            ForEach(nav.forms.jobSelector.middle) { project in
                                Panel.Row(
                                    config: Panel.RowConfiguration(
                                        text: project.name!,
                                        action: {setLastPanel(data: project.jobs!.allObjects)},
                                        entity: project,
                                        position: position
                                    )
                                )
                            }
                        } else {
                            Text("No company selected, or company has no projects")
                                .padding(10)
                        }
                        Spacer()
                    }
                } else if position == .last {
                    VStack(alignment: .leading, spacing: 1) {
                        if !nav.forms.jobSelector.last.isEmpty {
                            ForEach(nav.forms.jobSelector.last) { job in
                                Panel.Row(
                                    config: Panel.RowConfiguration(
                                        text: job.name ?? job.jid.string,
                                        action: {nav.session.job = job},
                                        entity: job,
                                        position: position
                                    )
                                )
                            }
                        } else {
                            Text("No job selected, or project has no jobs")
                                .padding(10)
                        }
                        Spacer()
                    }
                }
            }
        }
        .background(
            .white.opacity(0.05)
        )
        .frame(minHeight: 300)
    }
}

extension CompanyPanel {
    private func setMiddlePanel(data: [Any]) -> Void {
        nav.forms.jobSelector.currentPosition = position
        nav.forms.jobSelector.middle = data as! [Project]
        nav.forms.jobSelector.last = []
    }
    
    private func setLastPanel(data: [Any]) -> Void {
        nav.forms.jobSelector.currentPosition = position
        nav.forms.jobSelector.last = data as! [Job]
    }
    
    private func closePanel() -> Void {
        if position == .first {
            nav.forms.jobSelector.middle = []
            nav.forms.jobSelector.last = []
            nav.forms.jobSelector.selected = nil
        } else if position == .middle {
            nav.forms.jobSelector.middle = []
            nav.forms.jobSelector.last = []
        } else if position == .last {
            nav.forms.jobSelector.last = []
            nav.session.job = nil
        }
        
        showSearch = false
    }
}

struct ProjectPanel: View {
    public var position: Panel.Position
    
    @State private var showSearch: Bool = false
    @State private var searchText: String = ""

    @EnvironmentObject public var nav: Navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(alignment: .top) {
                Text("Projects").font(.title3)
                Spacer()
                FancySimpleButton(
                    text: "Search",
                    action: {showSearch.toggle()},
                    icon: "magnifyingglass",
                    showLabel: false,
                    showIcon: true,
                    type: .clear
                )
                FancySimpleButton(
                    text: "Close",
                    action: closePanel,
                    icon: "xmark",
                    showLabel: false,
                    showIcon: true
                )
                .disabled(nav.forms.jobSelector.middle.isEmpty)
                .opacity(nav.forms.jobSelector.middle.isEmpty ? 0.4 : 1)
            }
            .padding(10)
            
            if showSearch {
                SearchBar(text: $searchText)
            }

            if let _ = nav.forms.jobSelector.first {
                VStack(alignment: .leading, spacing: 1) {
                    if !nav.forms.jobSelector.middle.isEmpty {
                        ForEach(nav.forms.jobSelector.middle) { project in
                            Panel.Row(
                                config: Panel.RowConfiguration(
                                    text: project.name!,
                                    action: {setLastPanel(data: project.jobs!.allObjects)},
                                    entity: project,
                                    position: position
                                )
                            )
                        }
                    } else {
                        Text("No company selected, or company has no projects")
                            .padding(10)
                    }
                    Spacer()
                }
            }
        }
        .background(
            .white.opacity(0.05)
        )
        .frame(minHeight: 300)
    }
}

extension ProjectPanel {
    private func setLastPanel(data: [Any]) -> Void {
        nav.forms.jobSelector.currentPosition = position
        nav.forms.jobSelector.last = data as! [Job]
    }

    private func closePanel() -> Void {
        if position == .first {
            nav.forms.jobSelector.middle = []
            nav.forms.jobSelector.last = []
            nav.forms.jobSelector.selected = nil
        } else if position == .middle {
            nav.forms.jobSelector.middle = []
            nav.forms.jobSelector.last = []
        } else if position == .last {
            nav.forms.jobSelector.last = []
            nav.session.job = nil
        }
        
        showSearch = false
    }
}

public struct JobPanel: View {
    public var position: Panel.Position
    
    @State private var showSearch: Bool = false
    @State private var searchText: String = ""

    @EnvironmentObject public var nav: Navigation

    public var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(alignment: .top) {
                Text("Jobs").font(.title3)
                Spacer()
                FancySimpleButton(
                    text: "Search",
                    action: {showSearch.toggle()},
                    icon: "magnifyingglass",
                    showLabel: false,
                    showIcon: true,
                    type: .clear
                )
                FancySimpleButton(
                    text: "Close",
                    action: closePanel,
                    icon: "xmark",
                    showLabel: false,
                    showIcon: true
                )
                .disabled(nav.forms.jobSelector.last.isEmpty)
                .opacity(nav.forms.jobSelector.last.isEmpty ? 0.4 : 1)
            }
            .padding(10)
            
            if showSearch {
                SearchBar(text: $searchText)
            }

            if let _ = nav.forms.jobSelector.first {
                VStack(alignment: .leading, spacing: 1) {
                    if !nav.forms.jobSelector.last.isEmpty {
                        ForEach(nav.forms.jobSelector.last) { job in
                            Panel.Row(
                                config: Panel.RowConfiguration(
                                    text: job.name ?? job.jid.string,
                                    action: {nav.session.job = job},
                                    entity: job,
                                    position: position
                                )
                            )
                        }
                    } else {
                        Text("No job selected, or project has no jobs")
                            .padding(10)
                    }
                    Spacer()
                }
            }
        }
        .background(
            .white.opacity(0.05)
        )
        .frame(minHeight: 300)
    }
}

extension JobPanel {
    private func setLastPanel(data: [Any]) -> Void {
        nav.forms.jobSelector.currentPosition = position
        nav.forms.jobSelector.last = data as! [Job]
    }

    private func closePanel() -> Void {
        if position == .first {
            nav.forms.jobSelector.middle = []
            nav.forms.jobSelector.last = []
            nav.forms.jobSelector.selected = nil
        } else if position == .middle {
            nav.forms.jobSelector.middle = []
            nav.forms.jobSelector.last = []
        } else if position == .last {
            nav.forms.jobSelector.last = []
            nav.session.job = nil
        }
        
        showSearch = false
    }
}
