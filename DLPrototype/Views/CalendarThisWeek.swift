//
//  CalendarThisWeek.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2022-03-25.
//  Copyright © 2022 YegCollective. All rights reserved.
//

import SwiftUI

struct DayViewData: Identifiable, Hashable {
    public var id = UUID()
    public var dayOfWeek: String
    public var month: String
    public var day: String
    public var isWeekend: Bool = false
    public var tableData: String
}

struct CalendarThisWeek: View {
    public var data: String = ""
    
    @State private var thisWeek: [DayViewData] = []
    
    var body: some View {
        HStack {
            ForEach(thisWeek.reversed(), id: \.self) { data in
                DayView(viewData: data)
            }
        }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 100)
            .onAppear(perform: afterAppear)
    }
    
    private func afterAppear() -> Void {
        generateDateList()
    }
    
    private func getRelativeDate(_ relativeDate: Int) -> DayViewData {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        
        let calendar = Calendar.current
        
        let midnight = calendar.startOfDay(for: Date())
        let requestedDate = calendar.date(byAdding: .day, value: relativeDate, to: midnight)!
        let formatted = formatter.string(from: requestedDate)
        
        
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "EEEE"
        
        let dayOfWeek = dayOfWeekFormatter.string(from: requestedDate)
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        
        let month = monthFormatter.string(from: requestedDate)
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        
        let day = dayFormatter.string(from: requestedDate)
        
        let isWeekend: Bool = dayOfWeek.contains("Saturday") || dayOfWeek.contains("Sunday")
        
        
        let viewData = DayViewData(
            dayOfWeek: dayOfWeek,
            month: month,
            day: day,
            isWeekend: isWeekend,
            tableData: "hello"
        )
        
        return viewData
    }
    
    private func generateDateList() -> Void {
        for i in -1...5 {
            thisWeek.append(getRelativeDate(i * -1))
        }
    }
}

struct DayView: View {
    public var viewData: DayViewData
    
    var body: some View {
        ZStack {
            VStack {
//                Text(viewData.dayOfWeek)
//                    .frame(width: .infinity, height: .infinity, alignment: .top)
            }
            
            ZStack {
                Rectangle()
                    .foregroundColor(viewData.isWeekend ? Color.secondary : Color.orange)
            
                Button(action: selectDay, label: {
                    Image(systemName: "arrow.down.app.fill")
                })
                    .padding(15)
                    .font(.largeTitle)
                    .background(Color.black.opacity(0.2))
                    .clipShape(Circle())
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderless)
                
    //            Button(title, action: selectDay)
    //                .frame(minWidth: 0, maxWidth: .infinity)
    //                .padding()
    //                .frame(minWidth: 100, maxWidth: .infinity, minHeight: 10, maxHeight: .infinity)
    //                .overlay(
    //                        RoundedRectangle(cornerRadius: 25)
    //                            .foregroundColor(Color.orange)
    //                        )
            }
            
            VStack {
//                Text(viewData.dayOfWeek)
//                Text(viewData.month)
//                Text(viewData.day)
            }
        }
    }
    
    private func selectDay() -> Void {
//        print(data)
        let pasteBoard = NSPasteboard.general
        
        pasteBoard.clearContents()
        pasteBoard.setString(viewData.tableData, forType: .string)
    }
}

struct CalendarThisWeek_Previews: PreviewProvider {
    static var previews: some View {
        let data: String = "hi"
        
        CalendarThisWeek(data: data)
    }
}
