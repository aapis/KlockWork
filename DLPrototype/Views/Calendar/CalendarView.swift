//
//  Calendar.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2022-04-10.
//  Copyright © 2022 YegCollective. All rights reserved.
//

import SwiftUI

struct CalendarView: View {
    var body: some View {
        VStack {
            Text("EXPERIMENTAL - NON-FUNCTIONAL")
            CalendarThisWeek()
            CalendarThisWeek()
            CalendarThisWeek()
            CalendarThisWeek()
        }
        .padding()
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
