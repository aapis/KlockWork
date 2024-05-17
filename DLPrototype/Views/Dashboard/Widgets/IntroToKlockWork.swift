//
//  IntroToKlockWork.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2024-05-16.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct IntroToKlockWork: View {
    public let title: String = "Intro to KlockWork"
    
    @State private var companyName: String = ""
    @State private var projectName: String = ""
    @State private var jobName: String = ""
    @State private var noteName: String = ""
    @State private var taskName: String = ""

    @AppStorage("dashboard.widget.intro.createCompany") private var createCompany: Bool = false
    @AppStorage("dashboard.widget.intro.createProject") private var createProject: Bool = false
    @AppStorage("dashboard.widget.intro.createJob") private var createJob: Bool = false
    @AppStorage("dashboard.widget.intro.createNote") private var createNote: Bool = false
    @AppStorage("dashboard.widget.intro.createTask") private var createTask: Bool = false
    @AppStorage("dashboard.widget.intro.createPlan") private var createPlan: Bool = false
    @AppStorage("dashboard.widget.intro") public var showWidgetIntro: Bool = true

    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FancySubTitle(text: "\(title)", fgColour: .white)
                Spacer()
                FancyButtonv2(
                    text: "Close",
                    action: {showWidgetIntro.toggle()},
                    icon: "xmark",
                    showLabel: false,
                    showIcon: true,
                    size: .tiny,
                    type: .clear
                )
            }
            .padding()
            .background(Theme.darkBtnColour)

            VStack(alignment: .leading) {
                HStack {
                    Toggle("Create a Company", isOn: $createCompany)
                        .foregroundStyle(createCompany ? .gray : .white)
                    Spacer()
                    if createCompany {
                        Text(companyName)
                            .foregroundStyle(.gray)
                    }
                }
                HStack {
                    Toggle("Create a Project", isOn: $createProject)
                        .foregroundStyle(createProject ? .gray : .white)
                    Spacer()
                    if createProject {
                        Text(projectName)
                            .foregroundStyle(.gray)
                    }
                }
                HStack {
                    Toggle("Create a Job", isOn: $createJob)
                        .foregroundStyle(createJob ? .gray : .white)
                    Spacer()
                    if createJob {
                        Text(jobName)
                            .foregroundStyle(.gray)
                    }
                }
                HStack {
                    Toggle("Create a Note", isOn: $createNote)
                        .foregroundStyle(createNote ? .gray : .white)
                    Spacer()
                    if createNote {
                        Text(noteName)
                            .foregroundStyle(.gray)
                    }
                }
                HStack {
                    Toggle("Create a Task (or three!)", isOn: $createTask)
                        .foregroundStyle(createTask ? .gray : .white)
                    Spacer()
                }
                HStack {
                    Toggle("Create a Plan", isOn: $createPlan)
                        .foregroundStyle(createPlan ? .gray : .white)
                    Spacer()
                }
            }
            .padding([.leading, .trailing, .bottom])
            .padding(.top, 10)
            
            Spacer()
        }
        .background(Theme.cPurple)
        .onAppear(perform: onAppear)
        .frame(height: 250)
    }
    
    private func onAppear() -> Void {
        if let company = CoreDataCompanies(moc: moc).all().first {
            createCompany = true
            companyName = company.name ?? "_COMPANY_NAME"
        }

        if let project = CoreDataProjects(moc: moc).all().first {
            createProject = true
            projectName = project.name ?? "_PROJECT_NAME"
        }

        if let job = CoreDataJob(moc: moc).all().first {
            createJob = true
            jobName = job.jid.string
        }

        if let note = CoreDataNotes(moc: moc).all().first {
            createNote = true
            noteName = note.title ?? "_NOTE_TITLE"
        }

        if CoreDataTasks(moc: moc).countAll() > 0 {
            createTask = true
        }
        
        if let _ = CoreDataPlan(moc: moc).all().first {
            createPlan = true
        }
    }
}

#Preview {
    IntroToKlockWork()
}
