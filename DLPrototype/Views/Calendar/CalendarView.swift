//
//  Calendar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2022-04-10.
//  Copyright © 2022 YegCollective. All rights reserved.
//

import SwiftUI

struct CalendarView: View {
    public var category: Category
    @ObservedObject public var records: Records
    
    var body: some View {
        VStack {
            Text("EXPERIMENTAL - NON-FUNCTIONAL")
            CalendarThisWeek(records: records)
            CalendarThisWeek(records: records)
            CalendarThisWeek(records: records)
            CalendarThisWeek(records: records)
        }
        .padding()
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(category: Category(title: "Calendar"), records: Records())
    }
}
