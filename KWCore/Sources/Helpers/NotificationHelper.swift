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
    /// Remove delivered notifications with the same ID
    /// - Parameter identifier: String
    /// - Returns: Void
    static public func clean(identifier: String? = nil) -> Void {
        if let id = identifier {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }
    
    /// Create a new notification
    /// - Parameters:
    ///   - title: String
    ///   - body: String
    ///   - dateComponents: DateComponents
    ///   - identifier: String
    ///   - repeats: Bool(false)
    static public func create(title: String, body: String, dateComponents: DateComponents, identifier: String, repeats: Bool = false) {
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        self.clean(identifier: identifier)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification \(content.title) added")
            }
        }
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
}
