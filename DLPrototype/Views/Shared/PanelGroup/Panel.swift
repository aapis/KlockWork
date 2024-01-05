//
//  PanelGroup.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-01-04.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Panel: View {
    public var position: Position
    
    @State private var highlighted: Bool = false

    @EnvironmentObject private var nav: Navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack {
                switch position {
                case .first:
                    Text("Companies").font(.title3)
                    Spacer()
                case .middle:
                    Text("Projects").font(.title3)
                    Spacer()
                    FancySimpleButton(
                        text: "Close",
                        action: closePanel,
                        icon: "xmark",
                        showLabel: false,
                        showIcon: true
                    )
                case .last:
                    Text("Jobs").font(.title3)
                    Spacer()
                    FancySimpleButton(
                        text: "Close",
                        action: closePanel,
                        icon: "xmark",
                        showLabel: false,
                        showIcon: true
                    )
                }
            }
            .padding(3)

            if let firstColData = nav.forms.jobSelector.first {
                if position == .first {
                    if !firstColData.isEmpty {
                        ForEach(firstColData) { company in
                            HStack {
                                FancySimpleButton(
                                    text: company.name!,
                                    action: {setMiddlePanel(data: company.projects!.allObjects)},
                                    showLabel: true,
                                    showIcon: false,
                                    size: .link,
                                    type: .clear
                                )
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .padding(3)
                        }
                    } else {
                        Text("No companies found")
                    }
                } else if position == .middle {
                    if !nav.forms.jobSelector.middle.isEmpty {
                        ForEach(nav.forms.jobSelector.middle) { project in
                            HStack {
                                FancySimpleButton(
                                    text: project.name!,
                                    action: {setLastPanel(data: project.jobs!.allObjects)},
                                    showLabel: true,
                                    showIcon: false,
                                    size: .link,
                                    type: .clear
                                )
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .padding(3)
                        }
                    } else {
                        Text("No company selected, or company has no projects")
                    }
                } else if position == .last {
                    if !nav.forms.jobSelector.last.isEmpty {
                        ForEach(nav.forms.jobSelector.last) { job in
                            HStack {
                                FancySimpleButton(
                                    text: job.name ?? job.jid.string,
                                    action: {nav.session.job = job},
                                    showLabel: true,
                                    showIcon: false,
                                    size: .link,
                                    type: .clear
                                )
                                Spacer()
                                Image(systemName: "hammer")
                            }
                            .padding(3)
                        }
                    } else {
                        Text("No job selected, or project has no jobs")
                    }
                }
            }
        }
        .background(.white.opacity(0.05))
    }
}

extension Panel {
    private func setMiddlePanel(data: [Any]) -> Void {
        nav.forms.jobSelector.currentPosition = position
        nav.forms.jobSelector.middle = data as! [Project]
    }
    
    private func setLastPanel(data: [Any]) -> Void {
        nav.forms.jobSelector.currentPosition = .last
        nav.forms.jobSelector.last = data as! [Job]
    }
    
    private func closePanel() -> Void {
        if position == .middle {
            nav.forms.jobSelector.middle = []
        } else if position == .last {
            nav.forms.jobSelector.last = []
        }
        
        nav.session.job = nil
    }
}

extension Panel {
    public enum Orientation {
        case horizontal, vertical
    }
    
    public enum Position {
        case first, middle, last
    }
}
