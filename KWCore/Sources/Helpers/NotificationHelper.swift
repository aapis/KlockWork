//
//  NotificationHelper.swift
//  KlockWork
//
//  Created by Ryan Priebe on 2024-10-11.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import UserNotifications

final class NotificationHelper {
    static public let notificationTypeTask = UNNotificationCategory(
        identifier: "TASK",
        actions: [
            UNNotificationAction(identifier: "COMPLETE_ACTION", title: "Complete", options: []),
            UNNotificationAction(identifier: "DELAY_ACTION", title: "Delay", options: []),
            UNNotificationAction(identifier: "CANCEL_ACTION", title: "Cancel", options: [])
        ],
        intentIdentifiers: [],
        hiddenPreviewsBodyPlaceholder: "",
        options: .customDismissAction
    )

    /// Remove delivered notifications with the same ID
    /// - Parameter identifier: Optional(String)
    /// - Returns: Void
    static public func clean(identifier: String? = nil) -> Void {
        if let id = identifier {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }

    /// Remove notifications and set task.hasScheduledNotification to false
    /// - Parameter identifier: Optional(String)
    /// - Parameter task: LogTask
    /// - Returns: Void
    static public func clean(identifier: String? = nil, task: LogTask) -> Void {
        if let id = identifier {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }

        task.hasScheduledNotification = false
        PersistenceController.shared.save()
    }

    /// Create a new notification
    /// - Parameters:
    ///   - title: String
    ///   - task: LogTask
    ///   - minutesBefore: Int
    ///   - identifier: String
    ///   - repeats: Bool(false)
    static public func create(title: String, task: LogTask, minutesBefore: Int = 5, repeats: Bool = false) -> Void {
        if task.due == nil /*|| task.hasScheduledNotification == true*/ {
            return
        }

        let currHour = Calendar.autoupdatingCurrent.component(.hour, from: task.due!)
        let currMin = Calendar.autoupdatingCurrent.component(.minute, from: task.due!)

        // Don't create notifications for items whose due time is the very end of the day. Mainly to prevent
        // notification spam at midnight.
        if currHour == 23 && currMin == 59 {
            return
        }

        var dc = DateComponents()
        dc.hour = currHour
        if currMin > minutesBefore {
            dc.minute = currMin - minutesBefore
        } else {
            dc.minute = currMin
        }

        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = task.notificationBody
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "TASK"

        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: repeats)
        let request = UNNotificationRequest(identifier: task.id?.uuidString ?? "no-id", content: content, trigger: trigger)
        self.clean(identifier: task.id?.uuidString ?? "no-id")

        notificationCenter.setNotificationCategories(
            [
                NotificationHelper.notificationTypeTask
            ]
        )

        notificationCenter.add(request) { error in
            if error == nil {
                task.hasScheduledNotification = true
            } else {
                print("[error] Unable to create notification for task \(task.content ?? task.id?.uuidString ?? "Invalid")")
                print("[error] Error: \(String(describing: error?.localizedDescription))")
            }
        }

        PersistenceController.shared.save()
    }

    /// Request notification auth so we can send user notifications
    static public func requestAuthorization() {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    if granted {
                        print("Notification access granted.")
                    } else {
                        print("Notification access denied.\(String(describing: error?.localizedDescription))")
                    }
                }
                return
            case .denied:
                print("Notification access denied")
                return
            case .authorized:
                print("Notification access granted.")
                return
            default:
                return
            }
        }
    }
    
    /// Create notifications based on the user's chosen notification interval
    /// - Parameters:
    ///   - interval: Int
    ///   - task: LogTask
    /// - Returns: Void
    static public func createInterval(interval: Int, task: LogTask) -> Void {
        switch interval {
        case 1:
            NotificationHelper.create(title: "In 1 hour", task: task, minutesBefore: 60)
        case 2:
            NotificationHelper.create(title: "In 1 hour", task: task, minutesBefore: 60)
            NotificationHelper.create(title: "In 15 minutes", task: task, minutesBefore: 15)
        case 3:
            NotificationHelper.create(title: "In 1 hour", task: task, minutesBefore: 60)
            NotificationHelper.create(title: "In 15 minutes", task: task, minutesBefore: 15)
            NotificationHelper.create(title: "In 5 minutes", task: task)
        case 4:
            NotificationHelper.create(title: "In 15 minutes", task: task, minutesBefore: 15)
        case 5:
            NotificationHelper.create(title: "In 5 minutes", task: task)
        case 6:
            NotificationHelper.create(title: "In 15 minutes", task: task, minutesBefore: 15)
            NotificationHelper.create(title: "In 5 minutes", task: task)
        default:
            print("[warning] User has not set notifications.interval yet")
        }
    }

    /// Create notifications for upcoming due dates
    /// - Returns: Void
    static public func createNotifications(from upcoming: [LogTask], interval: Int) -> Void {
        for task in upcoming.prefix(10) {
            NotificationHelper.createInterval(interval: interval, task: task)
        }
    }

    // @TODO: from https://developer.apple.com/documentation/usernotifications/declaring-your-actionable-notification-types
    static public func handleNotificationActions(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Get the meeting ID from the original notification.
        let userInfo = response.notification.request.content.userInfo
        let meetingID = userInfo["MEETING_ID"] as! String
        let userID = userInfo["USER_ID"] as! String

        // Perform the task associated with the action.
        switch response.actionIdentifier {
        case "COMPLETE_ACTION":
//          sharedMeetingManager.acceptMeeting(user: userID, meetingID: meetingID)
          break

        case "DECLINE_ACTION":
//          sharedMeetingManager.declineMeeting(user: userID, meetingID: meetingID)
          break

        // Handle other actions...
        default:
          break
        }

        // Always call the completion handler when done.
        completionHandler()
    }
}
